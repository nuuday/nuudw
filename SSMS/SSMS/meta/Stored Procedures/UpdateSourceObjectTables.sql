/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the neccessary meta entries for incremental extract tables
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[UpdateSourceObjectTables]

@TableName NVARCHAR(100),
@SourceConnectionName NVARCHAR(100),
@ExtractSchemaName NVARCHAR(100),
@IsDateFlag BIT,
@IncrementalDefinition NVARCHAR(200),
@RollingWindowDays INT,
@ConnectionType NVARCHAR(50)

AS

SET NOCOUNT ON

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

/**********************************************************************************************************************************************************************
1. Update connections
***********************************************************************************************************************************************************************/
IF NOT EXISTS (SELECT TOP 1 [Name] FROM meta.SourceConnections WHERE Name = @SourceConnectionName)
BEGIN TRY				
	INSERT INTO meta.SourceConnections ([Name],[ExtractSchemaName])
	SELECT @SourceConnectionName,@ExtractSchemaName				
END TRY
BEGIN CATCH
	IF ERROR_NUMBER() <> 2627 -- Only react if this is not a "Violation of PRIMARY KEY constraint" error
	BEGIN
		SET @ErrorMessage = ERROR_MESSAGE();  
		SET @ErrorSeverity = ERROR_SEVERITY();  
		SET @ErrorState = ERROR_STATE();  
  
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
	END
END CATCH

/**********************************************************************************************************************************************************************
1. Update objects
***********************************************************************************************************************************************************************/
DECLARE @SourceConnectionID INT = (SELECT ID FROM meta.SourceConnections WHERE Name = @SourceConnectionName)

IF NOT EXISTS (SELECT SourceConnectionID, SchemaName, ObjectName FROM meta.SourceObjects WHERE SourceConnectionID = @SourceConnectionID AND ObjectName = @TableName)
BEGIN TRY
	INSERT INTO meta.SourceObjects (SourceConnectionID, SchemaName,ObjectName,PreserveHistoryFlag,IncrementalFlag)
	SELECT @SourceConnectionID, '', @TableName, 1, 1
END TRY
BEGIN CATCH
	IF ERROR_NUMBER() <> 2627 -- Only react if this is not a "Violation of PRIMARY KEY constraint" error
	BEGIN
		SET @ErrorMessage = ERROR_MESSAGE();  
		SET @ErrorSeverity = ERROR_SEVERITY();  
		SET @ErrorState = ERROR_STATE(); 
  
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
	END
END CATCH

/**********************************************************************************************************************************************************************
1. Update incremental setup
***********************************************************************************************************************************************************************/
DECLARE @SourceObjectID INT = (SELECT ID FROM meta.SourceObjects WHERE SourceConnectionID = @SourceConnectionID AND ObjectName = @TableName)

IF NOT EXISTS (SELECT SourceObjectID FROM meta.SourceObjectIncrementalSetup WHERE SourceObjectID = @SourceObjectID)
BEGIN
	BEGIN TRY
		INSERT INTO meta.SourceObjectIncrementalSetup (SourceObjectID, IncrementalValueColumnDefinitionInExtract,IsDateFlag,LastValueLoaded,RollingWindowDays)
		SELECT @SourceObjectID, @IncrementalDefinition, @IsDateFlag, CASE
																		WHEN @IsDateFlag = 1 AND @ConnectionType NOT IN ('Oracle','MSORA') THEN '19000101000000'
																		WHEN @IsDateFlag = 1 AND @ConnectionType IN ('Oracle','MSORA') THEN '01010101000000'
																		ELSE '0'																					
																	END, @RollingWindowDays;
	END TRY
	BEGIN CATCH
		IF ERROR_NUMBER() <> 2627 -- Only react if this is not a "Violation of PRIMARY KEY constraint" error
		BEGIN
			SET @ErrorMessage = ERROR_MESSAGE();  
			SET @ErrorSeverity = ERROR_SEVERITY();  
			SET @ErrorState = ERROR_STATE(); 
  
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
		END
	END CATCH
END
ELSE
BEGIN
	UPDATE meta.SourceObjectIncrementalSetup
	SET IncrementalValueColumnDefinitionInExtract = @IncrementalDefinition,
		IsDateFlag = @IsDateFlag,
		RollingWindowDays = @RollingWindowDays
	WHERE
		SourceObjectID = @SourceObjectID
END

SET NOCOUNT OFF