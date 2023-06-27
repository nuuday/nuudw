
CREATE PROCEDURE [stage].[Transform_Dim_FAM_SalesChannel]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_FAM_SalesChannel]

INSERT INTO stage.[Dim_FAM_SalesChannel] WITH (TABLOCK) ([FAM_SalesChannelKey], [SalesChannelName])
SELECT
	[FAM_SalesChannelKey] = 'Yousee',
	[SalesChannelName] = 'Yousee'
UNION ALL
SELECT
	[FAM_SalesChannelKey] = 'Erhverv',
	[SalesChannelName] = 'TDC Erhverv'