	


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create and execute the create or drop clustered column store index script and the rebuild or disable index script on fact tables. 
The script has the following charasteristic:
	- Indexes is maintained on facts
	- Clustered column store indexes is only created if the compatibility level is 120 or higher and the server version is Enterprise
***********************************************************************************************************************************************************************/


CREATE PROCEDURE [meta].[MaintainDWFactIndexes]

@Table VARCHAR(100),--Input is the table name without schema
@DestinationSchema VARCHAR(10),
@DisableIndexes BIT,--Input is 1 if you want to create indexes and 0 if you want to drop indexes
@PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10) 
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @DatabaseCollation NVARCHAR(100) = (SELECT CONVERT (varchar, DATABASEPROPERTYEX('' + @DatabaseNameDW + '','collation')))
DECLARE @CompatibilityLevelTable TABLE (CompatibilityLevel INT)
INSERT @CompatibilityLevelTable EXEC('(SELECT compatibility_level FROM sys.databases WHERE name COLLATE ' + @DatabaseCollation + ' = (SELECT VariableValue FROM meta.Variables WHERE VariableName = ''DatabaseNameDW''))')
DECLARE @CompatibilityLevel INT = (SELECT CompatibilityLevel FROM @CompatibilityLevelTable)
DECLARE @SQLEnterpriseServer BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'EnterpriseEditionFlag')
DECLARE @FactCCIFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactCCIFlag')
DECLARE @FactLoadEngine NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactLoadEngine')
DECLARE @IsCloudFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag')


/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
***********************************************************************************************************************************************************************/
DECLARE @FactIndex TABLE (IndexName NVARCHAR(128), OrdinalPosition INT, IsDisabled INT)
DECLARE @FactIndexSQL NVARCHAR(MAX) = IIF(@IsCloudFlag = 1,'','USE [' + @DatabaseNameDW + ']') + ' SELECT name,ROW_NUMBER() OVER (ORDER BY name), is_disabled FROM sys.indexes WHERE object_id = object_id(''' + @DestinationSchema + '.' + @Table + ''') AND type_desc NOT LIKE ''CLUSTERED%'' AND type_desc <> ''HEAP'''


INSERT @FactIndex EXEC(@FactIndexSQL)

/**********************************************************************************************************************************************************************
2. Create Loop counter variables
***********************************************************************************************************************************************************************/

DECLARE @Counter AS INT --Just a counter for the loop		
DECLARE @NumberOfColumns AS INT --Holds the number of columns in the table
								
SELECT 
	@Counter = 1,
	@NumberOfColumns = (SELECT MAX(OrdinalPosition) FROM @FactIndex)

/**********************************************************************************************************************************************************************
3. Create clustered columnstore index script
***********************************************************************************************************************************************************************/

DECLARE @ClusteredColumnStoreIndexScript NVARCHAR(MAX)

SET @ClusteredColumnStoreIndexScript = IIF(@IsCloudFlag = 1,'','USE [' + @DatabaseNameDW + ']') + @CRLF + CASE 
																				WHEN @DisableIndexes = 0 
																					THEN   'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''' + @DestinationSchema + '.' + @Table + ''') AND type_desc = ''CLUSTERED'' AND NAME <> ''CCI_'+ @Table + ''')
																							BEGIN
																							IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''' + @DestinationSchema + '.' + @Table + ''') AND NAME = ''CCI_'+ @Table + ''')' + @CRLF +
																							'CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @Table + '] ON [fact].[' + @Table + '] WITH (DROP_EXISTING = OFF)
																							END'

																				ELSE 

																							'IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''' + @DestinationSchema + '.' + @Table + ''') AND NAME = ''CCI_'+ @Table + ''')' + @CRLF +
																							'DROP INDEX [CCI_' + @Table + '] ON [fact].[' + @Table + ']'

																		  END

/**********************************************************************************************************************************************************************
4. Create disable index script
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderIndex NVARCHAR(MAX)
DECLARE @Index NVARCHAR(MAX)

WHILE @Counter <= @NumberOfColumns

BEGIN

	SELECT 
			@PlaceholderIndex =		   CASE 
											WHEN @DisableIndexes = 1 
												THEN IIF(IsDisabled = 1,'',IIF(@IsCloudFlag = 1,'','USE [' + @DatabaseNameDW + ']') + ' ALTER INDEX [' + IndexName + '] ON fact.' + @Table + ' DISABLE;') + @CRLF
											ELSE IIF(IsDisabled = 0,'',IIF(@IsCloudFlag = 1,'','USE [' + @DatabaseNameDW + ']') + ' ALTER INDEX [' + IndexName + '] ON fact.' + @Table + ' REBUILD;') + @CRLF 
									   END
									
	FROM 
		@FactIndex
	WHERE
		OrdinalPosition = @Counter

SET @Index = CONCAT(@Index,@PlaceholderIndex)

SET @PlaceholderIndex = ''

SET @Counter = @Counter + 1

END


/**********************************************************************************************************************************************************************
5. Execute dynamic SQL script variables
***********************************************************************************************************************************************************************/

/*Only executed if the destination schema is fact and SQL server is Enterprise and 2014 or higher*/

IF @DestinationSchema = 'fact'  

	BEGIN 

		IF @PrintSQL = 0

			BEGIN
		/*Only executed if the destination schema is fact and SQL server is Enterprise and 2014 or higher*/

				IF @CompatibilityLevel >= 120 AND @SQLEnterpriseServer = 1 AND @FactCCIFlag = 1 AND @FactLoadEngine = 'SSIS'

					BEGIN

						EXEC(@ClusteredColumnStoreIndexScript)

					END

				/*Only executed if the destination schema is fact*/

				EXEC(@Index)

			END

		ELSE

			BEGIN

				IF @CompatibilityLevel >= 120 AND @SQLEnterpriseServer = 1 AND @FactCCIFlag = 1 AND @FactLoadEngine = 'SSIS'

					BEGIN

						PRINT(@ClusteredColumnStoreIndexScript) + @CRLF + @CRLF

					END

				/*Only executed if the destination schema is fact*/

				PRINT(@Index)

			END

	END

SET NOCOUNT OFF