

CREATE PROCEDURE [meta].[UpdateVariables]

@DatabasePrefix NVARCHAR(100),
@DatabaseNameDW NVARCHAR(100),
@DatabaseNameStage NVARCHAR(100),
@DatabaseNameExtract NVARCHAR(100),
@DatabaseNameMeta NVARCHAR(100),
@IsCloudFlag BIT

AS

SET NOCOUNT ON

DECLARE @FactLoadEngine NVARCHAR(10) = (SELECT IIF(@IsCloudFlag = 1,'SQL','SSIS'))

IF @IsCloudFlag = 0

	BEGIN

		EXEC('
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabasePrefix'', @value=N''' + @DatabasePrefix + '''
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameDW'', @value=N''' + @DatabaseNameDW + ''' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameExtract'', @value=N''' + @DatabaseNameExtract + ''' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameStage'', @value=N''' + @DatabaseNameStage + ''' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameMeta'', @value=N''' + @DatabaseNameMeta + ''' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameTabular'', @value=N''' + @DatabasePrefix + 'Tabular''
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultDate'', @value=N''19000101'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultDimensionMemberID'', @value=N''-1'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultNumber'', @value=N''0'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultString'', @value=N''?'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultBit'', @value=N''0'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''SurrogateKeySuffix'', @value=N''ID'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''BusinessKeySuffix'', @value=N''Key'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''IsCloudFlag'', @value=N''' + @IsCloudFlag + '''
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''EnterpriseEditionFlag'', @value=N''1'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''FactCCIFlag'', @value=N''1'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''ExtractCCIFlag'', @value=N''0'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''ExtractCCIHistoryFlag'', @value=N''1'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''FactInMemoryFlag'', @value=N''1'' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''FactLoadEngine'', @value=N''' + @FactLoadEngine + ''' 
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''MaintainDWDropTableFlag'', @value=N''0''
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''MaintainDWDropViewFlag'', @value=N''0''
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''MaintainDWUpdateViewFlag'', @value=N''1''
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''ExtractControllerPattern'', @value=N''Standard''
		EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''LoadControllerPattern'', @value=N''Standard''')

	END

ELSE

	BEGIN

		EXEC('
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameDW'', @value=N''' + @DatabaseNameDW + ''' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameExtract'', @value=N''' + @DatabaseNameExtract + ''' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameStage'', @value=N''' + @DatabaseNameStage + ''' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DatabaseNameMeta'', @value=N''' + @DatabaseNameMeta + ''' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultDate'', @value=N''19000101'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultDimensionMemberID'', @value=N''-1'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultNumber'', @value=N''0'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultString'', @value=N''?'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''DefaultBit'', @value=N''0'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''SurrogateKeySuffix'', @value=N''ID'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''BusinessKeySuffix'', @value=N''Key'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''IsCloudFlag'', @value=N''' + @IsCloudFlag + '''
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''EnterpriseEditionFlag'', @value=N''1'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''FactCCIFlag'', @value=N''1'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''ExtractCCIFlag'', @value=N''0'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''ExtractCCIHistoryFlag'', @value=N''1'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''FactInMemoryFlag'', @value=N''0'' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''FactLoadEngine'', @value=N''' + @FactLoadEngine + ''' 
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''MaintainDWDropTableFlag'', @value=N''0''
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''MaintainDWDropViewFlag'', @value=N''0''
			EXEC [' + @DatabaseNameMeta + '].sys.sp_addextendedproperty @name=N''MaintainDWUpdateViewFlag'', @value=N''1''')

	END

SET NOCOUNT OFF