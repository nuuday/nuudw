
CREATE VIEW [sourceNuuDataCubus31PCTIView].[Cubus31PCTI_BUI_915_Customers_CU_History]
AS
SELECT 
	[LinkKundeID] ,
	[CustomerNumber] ,
	[AccountNumber] ,
	[HouseholdID] ,
	[Lid] ,
	[Segment] ,
	[PersonId] ,
	[SystemKtnavn] ,
	[ServiceProvCode] ,
	[Product] ,
	[Technology] ,
	[CVRnr] ,
	[OKunde] ,
	[Kvhx] ,
	[SRC_DWCreatedDate] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuuDataCubus31PCTI].[Cubus31PCTI_BUI_915_Customers_CU_History]
WHERE DWIsCurrent = 1