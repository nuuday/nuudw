﻿
CREATE VIEW [martView_PRX].[DimAddress]
AS
SELECT 	[AddressID],	[AddressKey],	[Street1],	[Street2],	[Postcode],	[City]
FROM [dimView].[Address]