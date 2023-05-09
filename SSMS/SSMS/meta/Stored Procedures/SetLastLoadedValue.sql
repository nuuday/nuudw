

/**********************************************************************************************************************************************************************
The purpose of this scripts is set LastValueLoaded in the table SourceObjectIncrementalSetup
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[SetLastLoadedValue] 

  @TableName NVARCHAR(100)
, @ExtractSchemaName NVARCHAR(100)
, @PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @ObjectID INT
DECLARE @IncrementalValueColumn NVARCHAR(500)
DECLARE @IsDateFlag BIT

SET @ObjectID = (
					SELECT SourceObjects.ID 
					FROM 
						meta.SourceObjects
					INNER JOIN
						(SELECT ID, ExtractSchemaName, ROW_NUMBER() OVER (PARTITION BY ExtractSchemaName ORDER BY ID) AS RowN FROM meta.SourceConnections) AS SourceConnections
							ON SourceConnections.ID = SourceObjects.SourceConnectionID
							AND RowN = 1
					WHERE 
						SourceObjects.ObjectName = @TableName
						AND SourceConnections.ExtractSchemaName = @ExtractSchemaName
				)

SET @IncrementalValueColumn =	(
									SELECT IIF(IncrementalValueColumnDefinitionInExtract <> '',IncrementalValueColumnDefinitionInExtract, IncrementalValueColumnDefinition)
									FROM meta.SourceObjectIncrementalSetup
									WHERE SourceObjectID = @ObjectID
								)

SET @IsDateFlag = (
					SELECT IsDateFlag
					FROM meta.SourceObjectIncrementalSetup
					WHERE SourceObjectID = @ObjectID
				)

/**********************************************************************************************************************************************************************
1. Execute dynamic SQL script variables
***********************************************************************************************************************************************************************/

DECLARE @SQL NVARCHAR(MAX) 


SET @SQL = 'UPDATE incremental_setup
 			SET [LastValueLoaded] = ISNULL((SELECT CONVERT(BIGINT, ' + iif (@IsDateFlag = 1,'FORMAT(MAX(' + @IncrementalValueColumn + '), ''yyyyMMddHHmmss''))', 
			'MAX(' + @IncrementalValueColumn + '))') + ' FROM [' + @ExtractSchemaName + '].[' + @TableName + ']), [LastValueLoaded])
			FROM 
				meta.SourceObjectIncrementalSetup as incremental_setup 
			INNER JOIN 
				meta.SourceObjects as source_objects 
			        on incremental_setup.SourceObjectID = source_objects.ID 
			INNER JOIN  
				meta.SourceConnections as source_connections 
					on source_objects.SourceConnectionID = source_connections.ID
  			WHERE
				source_connections.ExtractSchemaName + ''.'' + SUBSTRING(source_objects.ObjectName, CHARINDEX(''$'', source_objects.ObjectName) + 1, 200) = ''' + @ExtractSchemaName + '.' + @TableName + ''''

IF @PrintSQL = 1

	BEGIN
		PRINT(@SQL)
	END

ELSE
	
	BEGIN
		EXEC(@SQL)
	END



SET NOCOUNT OFF