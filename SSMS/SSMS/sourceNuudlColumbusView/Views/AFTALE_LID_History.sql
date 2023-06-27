
CREATE VIEW [sourceNuudlColumbusView].[AFTALE_LID_History]
AS
SELECT 
	[NUUDL_SourceCreated] ,
	[NUUDL_SourceUpdated] ,
	[ABM_NR] ,
	[ABONNEMENT_ID] ,
	[AENDRINGSSTATUS] ,
	[AFTALE_NR] ,
	[BEM_TEKST] ,
	[FAST_SPAERRING] ,
	[FJERNTELEFON] ,
	[FORBIND_ID] ,
	[GEN_DUT] ,
	[KUNDESAG_KD_AFS] ,
	[KUNDESAG_KD_OPR] ,
	[LID] ,
	[LID_STATUS] ,
	[MOMSFRI_MRK] ,
	[NAVNE_NR] ,
	[NBR_DUT] ,
	[OP_SOEGEFELT] ,
	[ORDRE_NR_AFS] ,
	[ORDRE_NR_OPR] ,
	[PRIS_SOEJLE] ,
	[SIDST_OPD_INIT] ,
	[SIDST_OPD_TSTMP] ,
	[SLUT_DATO] ,
	[START_DATO] ,
	[TLF_BOG_OPT_KD] ,
	[TRAFIK_OPSM_MRK] ,
	[UDSTIL_LID_MRK] ,
	[NUUDL_ID] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[BIZ_BatchCreatedID] ,
	[BIZ_BatchUpdatedID] ,
	[NUUDL_PKLatest] ,
	[NUUDL_CuratedBatchID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlColumbus].[AFTALE_LID_History]
WHERE DWIsCurrent = 1