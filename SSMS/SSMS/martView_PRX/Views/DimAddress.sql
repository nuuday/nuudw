﻿

CREATE VIEW [martView_PRX].[DimAddress]
AS
SELECT 
	[AddressID],
	[AddressKey],
	[Street1],
	[Street2],
	[Postcode],
	[City],
	[Floor],
	Suite,
	NAMID
FROM [dimView].[Address]