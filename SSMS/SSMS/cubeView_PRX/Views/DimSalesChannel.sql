﻿
CREATE VIEW [cubeView_PRX].[DimSalesChannel]
AS
SELECT 	[SalesChannelID],	[SalesChannelKey],	[SalesChannelName],	[SalesChannelLongName],	[SalesChannelType],	[InsurancePolicy],	[StoreAddress],	[StoreNumber],	[StoreName]
FROM [dimView].[SalesChannel]