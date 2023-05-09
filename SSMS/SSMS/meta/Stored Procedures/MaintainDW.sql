
/**********************************************************************************************************************************************************************
The purpose of this scripts is execute the maintaindw scripts in the correct order
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[MaintainDW]

@MasterTable VARCHAR(100),
@MasterDestinationSchema VARCHAR(10)

AS

SET NOCOUNT ON

DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @ViewName AS VARCHAR(MAX) = meta.SplitCamelCase(@MasterTable)
DECLARE @DropTableFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'MaintainDWDropTableFlag')
DECLARE @DropViewFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'MaintainDWDropViewFlag')
DECLARE @UpdateViewFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'MaintainDWUpdateViewFlag')
DECLARE @TableExists TABLE (TABLE_NAME VARCHAR(50)) --Table variable used to check if the table exists in the DW
DECLARE @TempTableExists TABLE (TABLE_NAME VARCHAR(50)) --Table variable used to check if the table exists in the DW
DECLARE @ViewExists TABLE (TABLE_NAME VARCHAR(50)) --Table variable used to check if the table exists in the DW
DECLARE @TempViewExists TABLE (TABLE_NAME VARCHAR(50)) --Table variable used to check if the table exists in the DW
DECLARE @IsCloudFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag')
DECLARE @ExistsInBM BIT = (SELECT IIF(TableName IS NULL,0,1) FROM meta.BusinessMatrix WHERE DestinationSchema = @MasterDestinationSchema AND TableName = @MasterTable)

INSERT @TableExists EXEC('SELECT TABLE_NAME FROM [' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @MasterTable + ''' AND TABLE_SCHEMA = ''' + @MasterDestinationSchema + '''')

INSERT @TempTableExists EXEC('SELECT TABLE_NAME FROM [' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @MasterTable + '_Temp'' AND TABLE_SCHEMA = ''' + @MasterDestinationSchema + '''')

INSERT @ViewExists EXEC('SELECT TABLE_NAME FROM [' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @ViewName + ''' AND TABLE_SCHEMA = ''' + @MasterDestinationSchema + 'View''')

INSERT @TempViewExists EXEC('SELECT TABLE_NAME FROM [' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @ViewName + '_Temp'' AND TABLE_SCHEMA = ''' + @MasterDestinationSchema + 'View''')


/**********************************************************************************************************************************************************************
1. Drop table and view
***********************************************************************************************************************************************************************/
IF @ExistsInBM = 1 --SafetyNet in order to prevent the procedure to run in production
	BEGIN
		IF @DropTableFlag = 1 AND EXISTS(SELECT * FROM @TableExists)               
			BEGIN
				EXEC('DROP TABLE [' + @DatabaseNameDW + '].[' +  @MasterDestinationSchema + '].[' + @MasterTable + ']')
			END

		IF @DropTableFlag = 1 AND EXISTS(SELECT * FROM @TempTableExists)               
			BEGIN
				EXEC('DROP TABLE [' + @DatabaseNameDW + '].[' +  @MasterDestinationSchema + '].[' + @MasterTable + '_Temp]')
			END

		IF @DropViewFlag = 1 AND EXISTS (SELECT * FROM @ViewExists)

			DECLARE @DropViewSQL NVARCHAR(MAX) = IIF(@IsCloudFlag = 1,'','USE [' + @DatabaseNameDW + ']') + 'DROP VIEW [' +  @MasterDestinationSchema + 'View].[' + @ViewName + ']'

			BEGIN
				EXEC(@DropViewSQL)
			END

		IF @DropViewFlag = 1 AND EXISTS (SELECT * FROM @TempViewExists)
		
			DECLARE @DropTempViewSQL NVARCHAR(MAX) = IIF(@IsCloudFlag = 1,'','USE [' + @DatabaseNameDW + ']') + 'DROP VIEW [' +  @MasterDestinationSchema + 'View].[' + @ViewName + '_Temp]'

			BEGIN
				EXEC(@DropTempViewSQL)
			END

		--Repopulate @TableExists and @ViewExists after potential drop
		DELETE FROM @TableExists
		DELETE FROM @ViewExists

		INSERT @TableExists EXEC('SELECT TABLE_NAME FROM [' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @MasterTable + ''' AND TABLE_SCHEMA = ''' + @MasterDestinationSchema + '''')
		INSERT @ViewExists EXEC('SELECT TABLE_NAME FROM [' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @ViewName + ''' AND TABLE_SCHEMA = ''' + @MasterDestinationSchema + 'View''')

/**********************************************************************************************************************************************************************
2. Execute 
***********************************************************************************************************************************************************************/


		IF NOT EXISTS (SELECT * FROM @ViewExists) AND EXISTS(SELECT * FROM @TableExists) --If table exists and view doesn't the table has to be updated prior to the view is created

			BEGIN
				EXECUTE meta.[MaintainDWUpdateTable] @Table = @MasterTable, @DestinationSchema = @MasterDestinationSchema, @PrintSQL = 0
				EXECUTE meta.[MaintainDWCreateTableAndView] @Table = @MasterTable,@DestinationSchema = @MasterDestinationSchema, @PrintSQL = 0

				IF @UpdateViewFlag = 1
					BEGIN
						EXECUTE meta.[MaintainDWUpdateView] @Table = @MasterTable, @DestinationSchema = @MasterDestinationSchema, @PrintSQL = 0
					END
			END

		ELSE
			BEGIN
				EXECUTE meta.[MaintainDWCreateTableAndView] @Table = @MasterTable,@DestinationSchema = @MasterDestinationSchema, @PrintSQL = 0
				EXECUTE meta.[MaintainDWUpdateTable] @Table = @MasterTable, @DestinationSchema = @MasterDestinationSchema, @PrintSQL = 0
				IF @UpdateViewFlag = 1
					BEGIN
						EXECUTE meta.[MaintainDWUpdateView] @Table = @MasterTable, @DestinationSchema = @MasterDestinationSchema, @PrintSQL = 0
					END
			END
	END
ELSE
	BEGIN
		PRINT('No entry in Business Matrix')
	END

SET NOCOUNT OFF