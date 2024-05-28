



CREATE VIEW [cubeView_PRX].[DimAddress]
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
	SubAddressDarId,
	[SubAddressMadId],
	KvhxId
FROM [dimView].[Address]