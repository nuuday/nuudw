/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-- Truncate tables before deployment to save time
PRINT 'Truncating tables before deployment';

IF OBJECT_ID('meta.[PreDeploymentCleanup]', 'P') IS NOT NULL
BEGIN 
	EXEC [meta].[PreDeploymentCleanup];
	PRINT 'Tables truncated';
END
ELSE
	PRINT 'Tables NOT truncated, as SPROC is not deployed yet';