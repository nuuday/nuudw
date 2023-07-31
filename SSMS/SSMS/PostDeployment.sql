/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/* ValidConnectionType */

DROP TABLE IF EXISTS #ValidConnectionType

SELECT 
	[ConnectionType]
	,[DelimitedIdentifier]
	,[Description]
INTO #ValidConnectionType
FROM [nuuMeta].[ValidConnectionType]
WHERE 1=0

INSERT INTO #ValidConnectionType
VALUES 
	('AzureDatabricksDeltaLake','Backtick',''),
	('SqlServer','Brackets','')

INSERT INTO [nuuMeta].[ValidConnectionType] (ConnectionType, DelimitedIdentifier, Description)
SELECT 
	[ConnectionType]
	,[DelimitedIdentifier]
	,[Description]
FROM #ValidConnectionType a
WHERE a.ConnectionType NOT IN (SELECT ConnectionType FROM nuuMeta.ValidConnectionType)


/* ValidDWObjectType */

DROP TABLE IF EXISTS #ValidDWObjectType

SELECT 
	[DWObjectType], [Description]
INTO #ValidDWObjectType
FROM [nuuMeta].ValidDWObjectType
WHERE 1=0

INSERT INTO #ValidDWObjectType ([DWObjectType], Description)
VALUES 
	('Dimension',''),
	('Fact',''),
	('Link',''),
	('Bridge','')

INSERT INTO [nuuMeta].ValidDWObjectType ([DWObjectType],  Description)
SELECT 
	[DWObjectType]
	,[Description]
FROM #ValidDWObjectType a
WHERE a.[DWObjectType] NOT IN (SELECT [DWObjectType] FROM nuuMeta.ValidDWObjectType)


/* ValidExtractPattern */

DROP TABLE IF EXISTS #ValidExtractPattern

SELECT 
	[ExtractPattern]
	,[Description]
INTO #ValidExtractPattern
FROM [nuuMeta].ValidExtractPattern
WHERE 1=0

INSERT INTO #ValidExtractPattern ([ExtractPattern], [Description])
VALUES 
	('Dummy','This is only used for production.'),
	('Incremental_History','The extract is able to fetch data incrementally from the source using the settings for watermark. The data is moved to a history table after the extract from the source. '),
	('Full','The data is extracted as a full load to the source table. Previous data is always truncated. No history is kept.')

INSERT INTO [nuuMeta].ValidExtractPattern ([ExtractPattern],  Description)
SELECT 
	[ExtractPattern]
	,[Description]
FROM #ValidExtractPattern a
WHERE a.[ExtractPattern] NOT IN (SELECT [ExtractPattern] FROM nuuMeta.ValidExtractPattern)


/* ValidHistoryType */

DROP TABLE IF EXISTS #ValidHistoryType

SELECT 
	HistoryType, [Description]
INTO #ValidHistoryType
FROM [nuuMeta].ValidHistoryType
WHERE 1=0

INSERT INTO #ValidHistoryType (HistoryType, Description)
VALUES 
	('None','History is not saved.'),
	('Type 1','Upon changes to the record old values are overwritten with the new version.'),
	('Type 2','Upon changes to the record the old row is deactivated and a new active row is added with the new values.')

INSERT INTO [nuuMeta].ValidHistoryType (HistoryType,  Description)
SELECT 
	HistoryType
	,[Description]
FROM #ValidHistoryType a
WHERE a.HistoryType NOT IN (SELECT HistoryType FROM nuuMeta.ValidHistoryType)


/* ValidLoadPattern */

DROP TABLE IF EXISTS #ValidLoadPattern

SELECT 
	LoadPattern, [Description]
INTO #ValidLoadPattern
FROM [nuuMeta].ValidLoadPattern
WHERE 1=0

INSERT INTO #ValidLoadPattern (LoadPattern, Description)
VALUES 
	('FactMerge','This pattern will transfer data from stage to the fact / bridge temp table with the correct surrogate keys. Afterwards the data are merged into the fact / bridge table on the primary key column.'),
	('FactAdd','This pattern will transfer data directly from stage to the fact / bridge table.'),
	('DimStandard','This pattern is for all dimensions.'),
	('FactFull','This will truncate and transfer data directly to the fact table.')

INSERT INTO [nuuMeta].ValidLoadPattern (LoadPattern,  Description)
SELECT 
	LoadPattern
	,[Description]
FROM #ValidLoadPattern a
WHERE a.LoadPattern NOT IN (SELECT LoadPattern FROM nuuMeta.ValidLoadPattern)