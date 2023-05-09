

/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the source SQL for extract packages
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[MaintainExtractCreateSourceScript] 

@SourceObjectID INT,
@PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @DatabaseNameExtract NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameExtract')
DECLARE @DefaultMaxDop NVARCHAR(3) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DefaultMaxDop')
	
/**********************************************************************************************************************************************************************
1. Update FrameworkMetaData table with IDs
***********************************************************************************************************************************************************************/
INSERT INTO meta.FrameworkMetaData
(SourceObjectID)

SELECT 
	SourceObjects.ID 
FROM 
	meta.SourceObjects 
LEFT JOIN 
	meta.FrameworkMetaData 
		ON FrameworkMetaData.SourceObjectID = SourceObjects.ID 
WHERE 
	FrameworkMetaData.BusinessMatrixID IS NULL
	AND FrameworkMetaData.SourceObjectID IS NULL	
	AND FrameworkMetaData.TargetObjectID IS NULL
	AND SourceObjects.ID = @SourceObjectID

DELETE FROM meta.FrameworkMetaData WHERE SourceObjectID NOT IN (SELECT ID FROM meta.SourceObjects) AND SourceObjectID IS NOT NULL;

/**********************************************************************************************************************************************************************
2. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DECLARE @InformationSchemaTables TABLE (SourceObjectID INT, TableName NVARCHAR(128), ObjectName NVARCHAR(128),OrdinalPosition INT, ParallelizationFlag BIT, PartitionFlag BIT, UseModulusFlag BIT, PartitionValueColumnDefinition NVARCHAR(200))
INSERT @InformationSchemaTables SELECT SourceObjectID,[Name], [ObjectName], ROW_NUMBER() OVER ( ORDER BY ObjectName), ParallelizationFlag, PartitionFlag, UseModulusFlag, PartitionValueColumnDefinition FROM meta.SourceObjectDefinitions WHERE SourceObjectID = @SourceObjectID GROUP BY SourceObjectID,Name,ObjectName, ParallelizationFlag, PartitionFlag, UseModulusFlag, PartitionValueColumnDefinition

/**********************************************************************************************************************************************************************
3. Create Loop counter variables
**********************************************************************************************************************************************************************/
DECLARE @OuterCounter INT = 1
DECLARE @MaxTable INT = (SELECT MAX(OrdinalPosition) FROM @InformationSchemaTables)


/**********************************************************************************************************************************************************************
4. Create outer loop
**********************************************************************************************************************************************************************/
DECLARE @Table NVARCHAR(50)  
DECLARE @ObjectName NVARCHAR(50)  
DECLARE @Parallelization BIT
DECLARE @Partition BIT
DECLARE @UseModulusFlag BIT
DECLARE @PartitionValueColumnDefinition NVARCHAR(200)

WHILE @OuterCounter <= @MaxTable

BEGIN

SELECT
 @Table = TableName
,@SourceObjectID = SourceObjectID
,@ObjectName = ObjectName
,@Parallelization = ParallelizationFlag
,@Partition = PartitionFlag
,@UseModulusFlag = UseModulusFlag
,@PartitionValueColumnDefinition = PartitionValueColumnDefinition
FROM 
@InformationSchemaTables
WHERE 
@OuterCounter = OrdinalPosition



/**********************************************************************************************************************************************************************
5. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DECLARE @Schemas TABLE (SourceConnectionID INT, SchemaName NVARCHAR(128), ExtractSchemaName NVARCHAR(128), OrdinalPosition INT)
DECLARE @InformationSchema TABLE (SourceConnectionID INT, TableName NVARCHAR(128),ColumnName NVARCHAR(128), SchemaName NVARCHAR(128), OrdinalPosition INT,DataType NVARCHAR(128), CharacterMaximumLength NVARCHAR(128), NumericPrecisionNumber INT ,SourceSystem NVARCHAR(128), OriginalDataType NVARCHAR(128), KeySequence INT)


INSERT @InformationSchema EXEC('WITH SourceData AS 
(SELECT 
   SourceConnectionID
  ,[TableName]
  ,MetaData.[ColumnName]
  ,[SchemaName]
  ,[OrdinalPositionNumber]
  ,[DataTypeName]
  ,[MaximumLenghtNumber]
  ,[NumericPrecisionNumber]
  ,[SourceSystemTypeName]
  ,IIF(SourceColumns.ColumnName IS NULL,0,1) AS TableHasColumnFilerFlag
  ,IIF(SourceColumns2.ColumnName IS NULL,0,1) AS ColumnFilerFlag
  ,[OriginalDataTypeName]
  ,[KeySequenceNumber]
  
   FROM 
		meta.ExtractInformationSchemaDefinitions AS MetaData
   LEFT JOIN
		meta.SourceColumns
			ON MetaData.SourceObjectID = SourceColumns.SourceObjectID
   LEFT JOIN
		meta.SourceColumns AS SourceColumns2
			ON MetaData.ColumnName = SourceColumns2.ColumnName
			AND MetaData.SourceObjectID = SourceColumns2.SourceObjectID 
   WHERE MetaData.SourceObjectID = ''' + @SourceObjectID + ''' 
   AND MetaData.ColumnName <> ''DWCreatedDate'')

SELECT   
   SourceConnectionID
  ,[TableName]
  ,[ColumnName]
  ,[SchemaName]
  ,ROW_NUMBER() OVER (PARTITION BY SourceConnectionID,TableName ORDER BY [OrdinalPositionNumber]) AS [OrdinalPositionNumber]
  ,[DataTypeName]
  ,[MaximumLenghtNumber]
  ,[NumericPrecisionNumber]
  ,[SourceSystemTypeName]
  ,[OriginalDataTypeName]
  ,[KeySequenceNumber]
FROM SourceData
WHERE TableHasColumnFilerFlag = ColumnFilerFlag
GROUP BY SourceConnectionID
  ,[TableName]
  ,[ColumnName]
  ,[SchemaName]
  ,[DataTypeName]
  ,[MaximumLenghtNumber]
  ,[NumericPrecisionNumber]
  ,[SourceSystemTypeName]
  ,[OrdinalPositionNumber]
  ,[OriginalDataTypeName]
  ,[KeySequenceNumber]')



INSERT @Schemas EXEC('SELECT SourceConnectionID, SchemaName, ExtractSchemaName,ROW_NUMBER() OVER (ORDER BY ExtractSchemaName)
FROM 
meta.ExtractInformationSchemaDefinitions AS MetaData
WHERE
MetaData.SourceObjectID = ''' + @SourceObjectID + '''
GROUP BY SourceConnectionID,ExtractSchemaName,SchemaName')

/**********************************************************************************************************************************************************************
6. Create Loop counter variables
**********************************************************************************************************************************************************************/
DECLARE @Counter INT
DECLARE @MaxColumns INT 
DECLARE @InnerCounter INT
DECLARE @MaxSchemas INT

SELECT 
@Counter = 1
   ,@InnerCounter = 1
   ,@MaxColumns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema)
   ,@MaxSchemas = (SELECT MAX(OrdinalPosition) FROM @Schemas)


/**********************************************************************************************************************************************************************
7. Create loop
**********************************************************************************************************************************************************************/
DECLARE @SourceTable NVARCHAR(MAX)
DECLARE @PlaceholderColumns NVARCHAR(MAX)
DECLARE @Columns NVARCHAR(MAX)
DECLARE @TableScript NVARCHAR(MAX)
DECLARE @Schema NVARCHAR(MAX)
DECLARE @ExtractSchema NVARCHAR(MAX)
DECLARE @ConnectionID INT
DECLARE @NavisionFlag BIT
DECLARE @RemoveBrackets BIT
DECLARE @OracleFlag BIT
DECLARE @MySQLFlag BIT
DECLARE @SQLScript NVARCHAR(MAX)
DECLARE @KeyColumn NVARCHAR(MAX) = IIF(@UseModulusFlag = 1 AND @Partition = 1, @PartitionValueColumnDefinition,(SELECT '[' + ColumnName + ']' FROM @InformationSchema WHERE KeySequence = 1))



WHILE @Counter <= @MaxSchemas

BEGIN

SELECT 
@Schema = ISNULL(SchemaName,''),
@ExtractSchema = ExtractSchemaName,
@ConnectionID = SourceConnectionID
FROM @Schemas
WHERE @Counter = OrdinalPosition 

SET @NavisionFlag = (SELECT NavisionFlag FROM meta.SourceConnections WHERE ID = @ConnectionID)
SET @RemoveBrackets = (SELECT RemoveBracketsFlag FROM meta.SourceConnections WHERE ID = @ConnectionID)
SET @OracleFlag = IIF((SELECT ConnectionType FROM meta.SourceConnections WHERE ID = @ConnectionID) = 'Oracle',1,0)
SET @MySQLFlag = IIF((SELECT ConnectionType FROM meta.SourceConnections WHERE ID = @ConnectionID) = 'MySQL',1,0)

/**********************************************************************************************************************************************************************
8. Create inner loop
**********************************************************************************************************************************************************************/


WHILE @InnerCounter <= @MaxColumns

BEGIN

	SELECT 
	@PlaceholderColumns = IIF(@InnerCounter = 1,'',',') 
													+ CASE 
														WHEN NumericPrecisionNumber > 36 THEN 'CAST([' + ColumnName + '] AS DECIMAL(36,12)) AS [' + ColumnName + ']'
														WHEN @MySQLFlag = 1 AND OriginalDataType = 'TIME' THEN 'CAST(' + ColumnName + ' AS CHAR) AS ' + ColumnName 
														WHEN @NavisionFlag = 1 AND ColumnName = 'timestamp' THEN 'CAST([' + ColumnName + '] AS BIGINT) AS [' + ColumnName + ']'
														ELSE '[' + ColumnName + ']'
													  END
													+ @CRLF				
	FROM @InformationSchema
	WHERE OrdinalPosition = @InnerCounter
	AND SchemaName = @Schema
	AND SourceConnectionID = @ConnectionID

	SET @Columns = CONCAT(@Columns,@PlaceholderColumns)
	SET @PlaceholderColumns = ''

	SET @InnerCounter = @InnerCounter + 1
	--Jacob �ndring:
	-- @OracleFlag=1 i stedet for ConnectionTye='Oracle'
END

SELECT
	 @SQLScript = 'SELECT ' + @Columns + IIF(@NavisionFlag = 1,',''@{item().NavisionCompany}'' AS DWNavisionCompany','') + ' FROM ' + @Schema + IIF(@Schema = '','','.') + '[' + IIF(@NavisionFlag = 1,'@{item().NavisionCompany}$','') + @Table + ']' + @CRLF + 
																				  CASE 
																					 WHEN ExtractSQLFilter = '' AND IncrementalFlag = 0 AND @Parallelization = 0 THEN ''
																					 WHEN ExtractSQLFilter = '' AND IncrementalFlag = 0 AND @Parallelization = 1 THEN 'WHERE ' + CASE WHEN @Partition = 0 OR (@Partition = 1 AND @UseModulusFlag = 1) THEN CASE
																																																																WHEN @OracleFlag = 1 THEN 'MOD(' + @KeyColumn + ',' + @DefaultMaxDop + ') = ''@{item().RowN}'''
																																																																ELSE @KeyColumn + ' % ' + @DefaultMaxDop + ' = ''@{item().RowN}'''
																																																														   END
																																													  WHEN @Partition = 1 AND @UseModulusFlag = 0 THEN '@{item().PartitionDefinition} >= ''@{item().PartitionLowerBound}'' AND @{item().PartitionDefinition} <= ''@{item().PartitionUpperBound}'''
																																												 END
																					 WHEN ExtractSQLFilter = '' AND IncrementalFlag = 1 AND @Parallelization = 0 THEN ' WHERE ' + IncrementalValueColumnDefinition + ' > ' +   CASE
																																																		WHEN IncrementalFlag = 1 AND @OracleFlag = 1 AND IsDateFlag = 1 THEN 'TO_DATE(''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'',''YYYYMMDDHH24MISS'')'
																																																		WHEN IncrementalFlag = 1 AND @OracleFlag = 0 AND ExtractPattern IN ('Standard','Navision','Replacement') AND IsDateFlag = 1 THEN 'convert(datetime, stuff(stuff(stuff(''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'', 9, 0, '' ''), 12, 0, '':''), 15, 0, '':''))'
																																																		ELSE '''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'''
																																																	END
																					 WHEN ExtractSQLFilter = '' AND IncrementalFlag = 1 AND @Parallelization = 1 THEN ' WHERE ' + IncrementalValueColumnDefinition + ' > ' +   CASE
																																																									WHEN IncrementalFlag = 1 AND @OracleFlag = 1 AND IsDateFlag = 1 THEN 'TO_DATE(''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'',''YYYYMMDDHH24MISS'')'
																																																									WHEN IncrementalFlag = 1 AND @OracleFlag = 0 AND ExtractPattern IN ('Standard','Navision','Replacement') AND IsDateFlag = 1 THEN 'convert(datetime, stuff(stuff(stuff(''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'', 9, 0, '' ''), 12, 0, '':''), 15, 0, '':''))'
																																																									ELSE '@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'
																																																								END  + CASE WHEN @Partition = 0 OR (@Partition = 1 AND @UseModulusFlag = 1) THEN CASE
																																																																														WHEN @OracleFlag = 1 THEN 'AND MOD(' + @KeyColumn + ',' + @DefaultMaxDop + ') = ''@{item().RowN}'''
																																																																														ELSE 'AND ' + @KeyColumn + ' % ' + @DefaultMaxDop + ' = ''@{item().RowN}'''
																																																																												   END
																																																											WHEN @Partition = 1 AND @UseModulusFlag = 0 THEN '@{item().PartitionDefinition} >= ''@{item().PartitionLowerBound}'' AND @{item().PartitionDefinition} <= ''@{item().PartitionUpperBound}'''
																																																									   END
																					 WHEN ExtractSQLFilter <> '' AND IncrementalFlag = 0 AND @Parallelization = 0 THEN 'WHERE ' + ExtractSQLFilter 
																					 WHEN ExtractSQLFilter <> '' AND IncrementalFlag = 0 AND @Parallelization = 1 THEN 'WHERE ' + ExtractSQLFilter +  CASE WHEN @Partition = 0 OR (@Partition = 1 AND @UseModulusFlag = 1) THEN CASE
																																																																					WHEN @OracleFlag = 1 THEN 'AND MOD(' + @KeyColumn + ',' + @DefaultMaxDop + ') = ''@{item().RowN}'''
																																																																					ELSE 'AND ' + @KeyColumn + ' % ' + @DefaultMaxDop + ' = ''@{item().RowN}'''
																																																																				END
																																																		   WHEN @Partition = 1 AND @UseModulusFlag = 0 THEN '@{item().PartitionDefinition} >= ''@{item().PartitionLowerBound}'' AND @{item().PartitionDefinition} <= ''@{item().PartitionUpperBound}'''
																																																	  END
																					 WHEN ExtractSQLFilter <> '' AND IncrementalFlag = 1 AND @Parallelization = 0 THEN 'WHERE ' + ExtractSQLFilter + ' AND ' + IncrementalValueColumnDefinition + ' > ' +      CASE
																																																																	WHEN IncrementalFlag = 1 AND @OracleFlag = 1 AND IsDateFlag = 1 THEN 'TO_DATE(''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'',''YYYYMMDDHH24MISS'')'
																																																																	WHEN IncrementalFlag = 1 AND @OracleFlag = 0 AND ExtractPattern IN ('Standard','Navision','Replacement') AND IsDateFlag = 1 THEN 'convert(datetime, stuff(stuff(stuff(''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'', 9, 0, '' ''), 12, 0, '':''), 15, 0, '':''))'
																																																																	ELSE '@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'
																																																																END
																					 WHEN ExtractSQLFilter <> '' AND IncrementalFlag = 1 AND @Parallelization = 1 THEN 'WHERE ' + ExtractSQLFilter + ' AND ' + IncrementalValueColumnDefinition + ' > ' +      CASE
																																																																	WHEN IncrementalFlag = 1 AND @OracleFlag = 1 AND IsDateFlag = 1 THEN 'TO_DATE(''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'',''YYYYMMDDHH24MISS'')'
																																																																	WHEN IncrementalFlag = 1 AND @OracleFlag = 0 AND ExtractPattern IN ('Standard','Navision','Replacement') AND IsDateFlag = 1 THEN 'convert(datetime, stuff(stuff(stuff(''@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'', 9, 0, '' ''), 12, 0, '':''), 15, 0, '':''))'
																																																																	ELSE '@{activity(''Lookup_LastValueLoaded'').output.firstRow.LastValueLoaded}'
																																																																END + CASE WHEN @Partition = 0 OR (@Partition = 1 AND @UseModulusFlag = 1) THEN CASE
																																																																																					WHEN @OracleFlag = 1 THEN 'AND MOD(' + @KeyColumn + ',' + @DefaultMaxDop + ') = ''@{item().RowN}'''
																																																																																					ELSE 'AND ' + @KeyColumn + ' % ' + @DefaultMaxDop + ' = ''@{item().RowN}'''
																																																																																				END
																																																																		   WHEN @Partition = 1 AND @UseModulusFlag = 0 THEN '@{item().PartitionDefinition} >= ''@{item().PartitionLowerBound}'' AND @{item().PartitionDefinition} <= ''@{item().PartitionUpperBound}'''
																																																																	  END
																				  END + @CRLF
																																												 
FROM meta.SourceObjects		
LEFT JOIN
	meta.SourceObjectIncrementalSetup
		ON SourceObjectIncrementalSetup.SourceObjectID = SourceObjects.ID
WHERE SourceObjects.ID = @SourceObjectID


/**********************************************************************************************************************************************************************
8. Update FrameworkMetaDate
**********************************************************************************************************************************************************************/

IF @PrintSQL = 0
	BEGIN
		UPDATE FrameworkMetaData
		SET SQLScript = IIF(@RemoveBrackets = 1 OR @OracleFlag = 1 OR @MySQLFlag = 1,REPLACE(REPLACE(@SQLScript,'[',''),']',''),@SQLScript)
		FROM meta.FrameworkMetaData
		INNER JOIN
			meta.SourceObjects
				ON SourceObjects.ID = FrameworkMetaData.SourceObjectID
				AND SourceObjects.SourceConnectionID = @ConnectionID
		LEFT JOIN
			meta.SourceObjectIncrementalSetup
				ON SourceObjectIncrementalSetup.SourceObjectID = SourceObjects.ID
		WHERE SourceObjects.ID = @SourceObjectID
	END
ELSE
	BEGIN
		PRINT(IIF(@RemoveBrackets = 1 OR @OracleFlag = 1 OR @MySQLFlag = 1,REPLACE(REPLACE(LEFT(@SQLScript,4000),'[',''),']',''),LEFT(@SQLScript,4000)))
		PRINT(IIF(@RemoveBrackets = 1 OR @OracleFlag = 1 OR @MySQLFlag = 1,REPLACE(REPLACE(SUBSTRING(@SQLScript,4001,4000),'[',''),']',''),SUBSTRING(@SQLScript,4001,4000)))
		PRINT(IIF(@RemoveBrackets = 1 OR @OracleFlag = 1 OR @MySQLFlag = 1,REPLACE(REPLACE(SUBSTRING(@SQLScript,8001,4000),'[',''),']',''),SUBSTRING(@SQLScript,8001,4000)))
	END

SET @InnerCounter = 1

SET @Schema = ''

SET @ExtractSchema = ''

SET @Columns = ''

SET @Counter = @Counter + 1

END

DELETE FROM @InformationSchema
DELETE FROM @Schemas


SET @Table = ''

SET @OuterCounter = @OuterCounter + 1

END