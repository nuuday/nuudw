
CREATE PROCEDURE [sourceNuudlNetCracker].Initiate_Filter_ibsitemshistory_History
AS

DROP TABLE IF EXISTS #ids
CREATE TABLE #ids (
	id nvarchar(36)
)


INSERT INTO #ids (id)
SELECT DISTINCT a.id
FROM [sourceNuudlNetCracker].[ibsitemshistory_History] a
INNER JOIN [sourceNuudlNetCracker].[pimnrmldistributionchannel_History] b
	ON b.id = a.item_json_distributionChannelId 
WHERE b.name IN ('Irma Showcase','Irma Shadow','YouSee Irma Showcase','YouSee Irma Shadow')
	AND state = 'PLANNED'


INSERT INTO #ids (id)
SELECT DISTINCT a.id
FROM [sourceNuudlNetCracker].[ibsitemshistory_History] a
INNER JOIN [sourceNuudlNetCracker].[pimnrmldistributionchannel_History] b
	ON b.id = a.item_json_distributionChannelId 
WHERE 
	EXISTS (SELECT * FROM #ids WHERE id = a.item_json_parentId)
	AND NOT EXISTS (SELECT * FROM #ids WHERE id = a.id)

INSERT INTO #ids (id)
SELECT DISTINCT a.id
FROM [sourceNuudlNetCracker].[ibsitemshistory_History] a
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] b
	ON b.id = a.item_json_offeringId
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

TRUNCATE TABLE [sourceNuudlNetCracker].[ibsitemshistory_History_Filter]
INSERT INTO [sourceNuudlNetCracker].[ibsitemshistory_History_Filter] (id)
SELECT DISTINCT id FROM #ids