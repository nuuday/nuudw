

CREATE PROCEDURE [stage].[Transform_Dim_FAM_OpenIncidentsGroup]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_FAM_OpenIncidentsGroup]

INSERT INTO stage.[Dim_FAM_OpenIncidentsGroup] WITH (TABLOCK) ( [FAM_OpenIncidentsGroupKey], [OpenIncidentsGroup] )
SELECT
	[FAM_OpenIncidentsGroupKey] = '1',
	[OpenIncidentsGroup] = '0-3 Days'
UNION ALL
SELECT
	[FAM_OpenIncidentsGroupKey] = '2',
	[OpenIncidentsGroup] = '4-7 Days'
UNION ALL
SELECT
	[FAM_OpenIncidentsGroupKey] = '3',
	[OpenIncidentsGroup] = '8-14 Days'
UNION ALL
SELECT
	[FAM_OpenIncidentsGroupKey] = '4',
	[OpenIncidentsGroup] = '15-28 Days'
UNION ALL
SELECT
	[FAM_OpenIncidentsGroupKey] = '5',
	[OpenIncidentsGroup] = '29-35 Days'
UNION ALL
SELECT
	[FAM_OpenIncidentsGroupKey] = '6',
	[OpenIncidentsGroup] = '36-49 Days'
UNION ALL
SELECT
	[FAM_OpenIncidentsGroupKey] = '7',
	[OpenIncidentsGroup] = '49+ Days'