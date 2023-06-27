﻿


CREATE VIEW [SourceNuudlBIZView].[DimProduct_History]
AS
SELECT 
	[NUUDL_SourceCreated] ,
	[NUUDL_SourceUpdated] ,
	[ProductKey] ,
	[DimEditor_Updated_TS] ,
	[DimEditor_Created_TS] ,
	[DimEditor_Created_By] ,
	[ProductID] ,
	[SourceSystem] ,
	[Downstream] ,
	[ETL_AntalLinier] ,
	[ETL_FlowRelevant] ,
	[ETL_ProduktInfo] ,
	[ETL_ProduktKobling] ,
	[ETL_TekstRelevant] ,
	[IsWholesale] ,
	[ProductBrandCategory] ,
	[ProductCategory] ,
	[ProductChange] ,
	[ProductChangeCategory] ,
	[ProductMainCategory] ,
	[ProductName] ,
	[ProductNetworkTechnology] ,
	[ProductSubCategory] ,
	[ProductTargetCustomer] ,
	[ProductTransmissionTechnology] ,
	[ProductType] ,
	[SalesEffectiveDate] ,
	[SalesExperiationDate] ,
	[ServiceType] ,
	[SourceCreatedDate] ,
	[SourceEffectiveDate] ,
	[SourceExpirationDate] ,
	[SourceUpdatedBy] ,
	[SourceUpdatedDate] ,
	[Upstream] ,
	[NUUDL_ID] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[BIZ_BatchCreatedID] ,
	[BIZ_BatchUpdatedID] ,
	[NUUDL_PKLatest] ,
	[SAF_Attr] ,
	[ETL_SAFFlowrelevant] ,
	[ETL_SAFFlowrelevantDate] ,
	[Niv1] ,
	[Niv2] ,
	[Niv3] ,
	[Niv4] ,
	[ProductSubCategory2] ,
	[BellisPrioritet] ,
	[Bemaerkning] ,
	[CallDirectionFrom] ,
	[CallDirectionTo] ,
	[Landekode] ,
	[Source_Created_By] ,
	[Source_Updated_By] ,
	[TrafficAddon] ,
	[Volumetype] ,
	[BundleType] ,
	[Technology] ,
	[ProductWeight] ,
	[NUUDL_CuratedBatchID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [SourceNuudlBIZ].[DimProduct_History]
--WHERE DWIsCurrent = 1
WHERE DWValidFromDate <> DWValidToDate