

CREATE PROCEDURE [meta].[DropStageTablesFromBusinessMatrix]

AS

SET NOCOUNT ON

DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @Drop VARCHAR(MAX)
DECLARE @Counter INT = 1
DECLARE @MaxID INT 
DECLARE @InformationSchema TABLE (TABLE_NAME NVARCHAR(128), ORDINAL_POSITION INT)

INSERT @InformationSchema EXEC('SELECT DISTINCT TABLE_NAME 
											   ,ROW_NUMBER() OVER (ORDER BY TABLE_NAME) AS ORDINAL_POSITION
								FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = ''DummyColumn''')

SET @MaxID = (SELECT MAX(ORDINAL_POSITION) FROM @InformationSchema)

WHILE  @Counter <= @MaxID

BEGIN

SELECT @Drop = 'DROP TABLE [' + @DatabaseNameStage + '].stage.[' + TABLE_NAME + ']'

FROM @InformationSchema
WHERE @Counter = ORDINAL_POSITION

EXEC(@Drop)

SET @Counter = @Counter + 1

END

SET NOCOUNT OFF