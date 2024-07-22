
CREATE PROCEDURE [stage].[Transform_Dim_SalesChannel]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_SalesChannel]

INSERT INTO stage.[Dim_SalesChannel] WITH (TABLOCK) ( [SalesChannelKey], [SalesChannelName], [SalesChannelLongName], [SalesChannelType],[InsurancePolicy], [StoreAddress], [StoreNumber], [storeName])
SELECT
    CONVERT( NVARCHAR(36), pndc.id ) AS SalesChannelKey,
    CONVERT( NVARCHAR(50), ISNULL( NULLIF( pndc.[name], '' ), '?' ) ) AS SalesChannelName,
    CONVERT( NVARCHAR(50), ISNULL( NULLIF( pndc.[localized_name_json_dan], '' ), '?' ) ) AS SalesChannelLongName,
    CONVERT( NVARCHAR(50), ISNULL( NULLIF( pndc.[extended_parameters_json_channelType], '' ), '?' ) ) AS SalesChannelType,
    CONVERT( NVARCHAR(50), ISNULL( NULLIF( pndc.[extended_parameters_json_insurancePolicyPrefix], '' ), '?' ) ) AS InsurancePolicy,
    CONVERT( NVARCHAR(250), ISNULL( NULLIF( pndc.[extended_parameters_json_storeAddress], '' ), '?' ) ) AS StoreAddress,
    CONVERT( NVARCHAR(20), ISNULL( NULLIF( pndc.[extended_parameters_json_storeID], '' ), '?' ) ) AS StoreNumber,
    CONVERT( NVARCHAR(50), ISNULL( NULLIF( pndc.[extended_parameters_json_storeName], '' ), '?' ) ) AS StoreName
FROM sourceNuudlNetCrackerView.pimnrmldistributionchannel_History pndc