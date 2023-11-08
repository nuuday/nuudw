CREATE PROCEDURE [nuuMeta].[MaintainDWCreateMartViews]
	@Solution nvarchar(10)
AS
/*
DECLARE @Solution nvarchar(10) = 'PRX'
--*/

SET @Solution = UPPER(@Solution)

DECLARE 
	@DWSchema sysname
	, @DWView sysname
	, @SolutionSchema sysname
	, @SolutionView sysname
	, @SQL nvarchar(max)
	, @ColumnList nvarchar(max)


SET @SolutionSchema  = 'martView_'  +@Solution

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = @SolutionSchema)
BEGIN

	SET @SQL = 'CREATE SCHEMA '+@SolutionSchema+' AUTHORIZATION dbo'

	EXEC (@SQL)

END

DECLARE dbcursor CURSOR FOR
	SELECT 
		CASE 
			WHEN dwo.DWObjectType = 'Dimension' THEN 'dimView'
			WHEN dwo.DWObjectType = 'Fact' THEN 'factView'
			WHEN dwo.DWObjectType = 'Bridge' THEN 'bridgeView'
		END DWSchema,
		dwo.DWObjectName,		
		@SolutionSchema AS SolutionSchema,
		CASE 
			WHEN dwo.DWObjectType = 'Dimension' THEN 'Dim'
			WHEN dwo.DWObjectType = 'Fact' THEN 'Fact'
			WHEN dwo.DWObjectType = 'Bridge' THEN 'Bridge'
		END + dwo.DWObjectName SolutionView
		--,cs.value AS Solution
	FROM nuuMeta.DWObject dwo
	CROSS APPLY STRING_SPLIT(REPLACE(TRANSLATE(CubeSolutions,char(9)+char(13)+char(10)+'['+']','     '),' ',''),',') cs /* Remove blank, tab, line feed, carriage return and split string */
	WHERE cs.value = @Solution
	ORDER BY SolutionView

OPEN dbcursor

FETCH NEXT FROM dbcursor INTO @DWSchema, @DWView, @SolutionSchema, @SolutionView

WHILE @@FETCH_STATUS = 0
BEGIN
	
	SELECT @ColumnList = STRING_AGG(char(13)+char(9)+'['+COLUMN_NAME+']',',') WITHIN GROUP (ORDER BY ORDINAL_POSITION)
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @DWSchema AND TABLE_NAME = @DWView
		AND COLUMN_NAME NOT LIKE 'DW%'

	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @SolutionSchema AND TABLE_NAME = @SolutionView)
	BEGIN

		SET @SQL = '
CREATE VIEW ['+@SolutionSchema+'].['+@SolutionView+']
AS
SELECT '+@ColumnList+'
FROM ['+@DWSchema+'].['+@DWView+']
	'
		--PRINT @SQL
		EXEC (@SQL)

		PRINT 'Created '+'['+@SolutionSchema+'].['+@SolutionView+']'

	END

	FETCH NEXT FROM dbcursor INTO @DWSchema, @DWView, @SolutionSchema, @SolutionView

END

CLOSE dbcursor
DEALLOCATE dbcursor