
CREATE VIEW [sourceNuudlColumbusView].[PROD_LID_AFT_History]
AS
SELECT 
	[NUUDL_SourceCreated] ,
	[NUUDL_SourceUpdated] ,
	[ABONNEMENT_ID] ,
	[AENDRINGSSTATUS] ,
	[AFSAET_KODE] ,
	[ANTAL_PRODUKT] ,
	[ARBITRAER_PRIS] ,
	[B_SLUT_DATO] ,
	[FUNKTIONS_NR] ,
	[IDRIFT_MRK] ,
	[KUNDE_PRIS_AFT_NO] ,
	[LID_LOEBE_ID] ,
	[ORDRE_NR_OPR] ,
	[PROD_LID_AFT_ID] ,
	[PRODUKT_ELM_NR] ,
	[PRODUKT_GRP_NR] ,
	[RABAT_LOEB] ,
	[RABAT_LOEB_SAT] ,
	[REGNINGS_BEM] ,
	[SIDST_OPD_INIT] ,
	[SIDST_OPD_TSTMP] ,
	[START_DATO] ,
	[TEKST_MRK] ,
	[UNDERLEV_ID] ,
	[NUUDL_ID] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[BIZ_BatchCreatedID] ,
	[BIZ_BatchUpdatedID] ,
	[NUUDL_PKLatest] ,
	[K_MRK_DATO] ,
	[NUUDL_CuratedBatchID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlColumbus].[PROD_LID_AFT_History]
WHERE DWIsCurrent = 1