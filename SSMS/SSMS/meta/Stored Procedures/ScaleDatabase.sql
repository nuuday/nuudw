

CREATE PROCEDURE [meta].[ScaleDatabase] 

@DatabaseSkuName NVARCHAR(20)
			
AS 

SET NOCOUNT ON
		
EXEC('ALTER DATABASE [<%DatabaseNameDW%>] MODIFY (SERVICE_OBJECTIVE = ''' + @DatabaseSkuName + ''')')

SET NOCOUNT OFF
