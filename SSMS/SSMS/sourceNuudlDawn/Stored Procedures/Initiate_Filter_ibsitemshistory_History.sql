


CREATE PROCEDURE [sourceNuudlDawn].[Initiate_Filter_ibsitemshistory_History]
AS

DROP TABLE IF EXISTS #ids
CREATE TABLE #ids (
	id nvarchar(36)
)

--we are excluding those subscriptions because of data issues due to testing activities in production
INSERT INTO #ids (id) 
VALUES 
	('b5beb355-0379-41f2-aaad-47297c9548cb')
	, ('39476242-7ab7-467e-b88a-b3968a8cb7e9')
	, ('603fcbc4-e83f-443c-adf9-e6ed2b28a307')


INSERT INTO #ids (id)
SELECT DISTINCT a.id
FROM [sourceNuudlDawn].[ibsitemshistory_History] a
INNER JOIN [sourceNuudlNetCracker].[pimnrmldistributionchannel_History] b
	ON b.id = a.item_distributionChannelId 
WHERE b.name IN ('Irma Showcase','Irma Shadow','YouSee Irma Showcase','YouSee Irma Shadow')
	AND state = 'PLANNED'


INSERT INTO #ids (id)
SELECT DISTINCT a.id
FROM [sourceNuudlDawn].[ibsitemshistory_History] a
INNER JOIN [sourceNuudlNetCracker].[pimnrmldistributionchannel_History] b
	ON b.id = a.item_distributionChannelId 
WHERE 
	EXISTS (SELECT * FROM #ids WHERE id = a.item_parentId)
	AND NOT EXISTS (SELECT * FROM #ids WHERE id = a.id)

INSERT INTO #ids (id)
SELECT DISTINCT a.id
FROM [sourceNuudlDawn].[ibsitemshistory_History] a
LEFT JOIN [sourceNuudlNetCracker].[pimnrmlproductoffering_History] b
	ON b.id = a.item_offeringId
WHERE 
	a.active_from < '2024-02-06'
	AND extended_parameters_json_deviceType IS NULL
	AND b.name NOT IN (
		'Sign-up Fee',
		'Bags',
		'Broadband Modems',
		'Handsets',
		'Insurance',
		'Insurance Upfront Fee',
		'Landline Phone',
		'Modems',
		'Smart Watches',
		'Tablets',
		'Vouchers',
		'Equipment Reverse Charge',
		'Accessories'
	)

TRUNCATE TABLE [sourceNuudlDawn].[ibsitemshistory_History_Filter]
INSERT INTO [sourceNuudlDawn].[ibsitemshistory_History_Filter] (id)
SELECT DISTINCT id FROM #ids