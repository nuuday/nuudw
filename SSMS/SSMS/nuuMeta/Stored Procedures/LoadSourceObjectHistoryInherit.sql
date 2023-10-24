


CREATE PROCEDURE [nuuMeta].[LoadSourceObjectHistoryInherit] 
	@ExtractTable  NVARCHAR(200),--Input is the extract table with schema
	@PrintSQL BIT = 0

AS

SET NOCOUNT ON

/*
DECLARE 
	@ExtractTable NVARCHAR(200) = 'sourceNuudlNetcracker.cimcustomer',
	@PrintSQL BIT = 1
--*/

/*
This procedure saves incremental load from the extract table into the history table. 
It only saves neweste version of the source. If the same key is sent again it will be removed from the history table before the new version is inserted.
*/

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @TableSchema NVARCHAR(100) = LEFT(@ExtractTable,CHARINDEX('.',@ExtractTable,0)-1)
DECLARE @Table NVARCHAR(100) = REPLACE(REPLACE(REPLACE(@ExtractTable,CONCAT(@TableSchema,'.'),''),'[',''),']','')
DECLARE @HistoryTable NVARCHAR(100) = @Table + '_History'
DECLARE @HistorySchema NVARCHAR(50) = @TableSchema

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
**********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (TableName NVARCHAR(128), ColumnName NVARCHAR(128), PrimaryKey INT)

INSERT INTO @InformationSchema (TableName, ColumnName, PrimaryKey)
SELECT
	COLUMNS.TABLE_NAME,
	COLUMNS.COLUMN_NAME,
	CASE
		WHEN KEY_COLUMN_USAGE.COLUMN_NAME IS NULL THEN 0
		ELSE 1
	END AS PRIMARY_KEY
FROM INFORMATION_SCHEMA.COLUMNS
LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	ON COLUMNS.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME
		AND COLUMNS.COLUMN_NAME = KEY_COLUMN_USAGE.COLUMN_NAME
		AND COLUMNS.TABLE_SCHEMA = KEY_COLUMN_USAGE.TABLE_SCHEMA
WHERE
	COLUMNS.TABLE_NAME = @Table
	AND COLUMNS.TABLE_SCHEMA = @TableSchema
	AND COLUMNS.COLUMN_NAME NOT LIKE 'DW%'
	--AND COLUMNS.COLUMN_NAME NOT IN ('DWCreatedDate','DWIsCurrent','DWValidFromDate','DWValidToDate','DWCreatedDate','DWModifiedDate','DWIsDeletedInSource','DWDeletedInSourceDate')


/**********************************************************************************************************************************************************************
2. Fill out the dynamic SQL script variables
**********************************************************************************************************************************************************************/

DECLARE @Parameters NVARCHAR(MAX) --Holds the parameter part of the Merge Join Script
DECLARE @Delete NVARCHAR(MAX) = '' --Holds the DELETE Part of the Script
DECLARE @Insert NVARCHAR(MAX) --Holds the INSERT Part of the Script
DECLARE @FullScript NVARCHAR(MAX) --Combining @Parameters,@Delete,@Insert
DECLARE @ColumnList NVARCHAR(MAX) = (SELECT STRING_AGG('['+ColumnName+']',',') FROM @InformationSchema)
DECLARE @PKColumnJoin NVARCHAR(MAX) = (SELECT STRING_AGG(' his.['+ColumnName+'] = ext.['+ColumnName+']',' AND') FROM @InformationSchema WHERE PrimaryKey = 1)
DECLARE @ValidFrom NVARCHAR(4000) 
DECLARE @ValidTo NVARCHAR(4000)  
DECLARE @IsCurrent NVARCHAR(4000) 

SELECT 
	@ValidFrom = ISNULL(MAX(CASE WHEN ColumnName = 'NUUDL_ValidFrom' THEN '['+ColumnName+']' END),'@MinDateTime'),
	@ValidTo = ISNULL(MAX(CASE WHEN ColumnName = 'NUUDL_ValidTo' THEN '['+ColumnName+']' END),'@MaxDateTime'),
	@IsCurrent = ISNULL(MAX(CASE WHEN ColumnName = 'NUUDL_PKLatest' THEN '['+ColumnName+']' END),'@BooleanTrue')
FROM @InformationSchema 


SET @Parameters =
'DECLARE @CurrentDateTime datetime
DECLARE @MinDateTime datetime
DECLARE @MaxDateTime datetime
DECLARE @BooleanTrue bit
DECLARE @BooleanFalse bit
DECLARE @DateToDateTime datetime


SELECT
	@CurrentDateTime = cast(getdate() as datetime),
	@MinDateTime = cast(''1900-01-01'' as datetime),
	@MaxDateTime = cast(''9999-12-31'' as datetime),
	@BooleanTrue = cast(1 as bit),
	@BooleanFalse = cast(0 as bit),
	@DateToDateTime = getdate()
'

IF @PKColumnJoin IS NOT NULL
BEGIN

	SET @Delete = '
-- ==================================================
-- DELETE
-- ==================================================

DELETE FROM his 
FROM [' + @HistorySchema + '].[' + @HistoryTable +'] AS his
INNER JOIN [' + @TableSchema + '].[' + @Table + '] AS ext ON ' + @PKColumnJoin +'

'

END

SET @Insert =
'
-- ==================================================
-- INSERT
-- ==================================================

INSERT INTO [' + @HistorySchema + '].[' + @HistoryTable +']
(' + @ColumnList + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
)
SELECT 
' + @ColumnList + '
,'+@IsCurrent+' as [DWIsCurrent]
,'+@ValidFrom+' as [DWValidFromDate]
,'+@ValidTo+' as [DWValidToDate]
,@CurrentDateTime as [DWCreatedDate]
,@CurrentDateTime as [DWModifiedDate]
,@BooleanFalse as [DWIsDeletedInSource]
,@MinDateTime as [DWDeletedInSourceDate]
FROM [' + @TableSchema + '].[' + @Table + ']'


SET @FullScript = CONCAT(@Parameters, @Delete, @Insert)	

/**********************************************************************************************************************************************************************
5. Execute dynamic SQL script variables
**********************************************************************************************************************************************************************/

IF @PrintSQL = 0
BEGIN
	EXEC(@FullScript)
END

ELSE
BEGIN
	SELECT CAST('<?ClickToSeeCode --'+CHAR(13)+CHAR(10)+@FullScript+CHAR(13)+CHAR(10)+ '-- ?>' AS XML) FullScript
	PRINT(@FullScript)
END

SET NOCOUNT OFF