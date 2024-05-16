



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
	DarId,
	MadId,
	KvhxId
FROM [dimView].[Address]