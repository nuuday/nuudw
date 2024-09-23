



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
	NAMID,
	[SubAddressDarId],
	[SubAddressMadId],
	--KvhxId,
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Address]