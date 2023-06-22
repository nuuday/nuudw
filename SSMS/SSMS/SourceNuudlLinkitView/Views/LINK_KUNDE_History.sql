
CREATE VIEW [SourceNuudlLinkitView].[LINK_KUNDE_History]
AS
SELECT 
	[NUUDL_SourceCreated] ,
	[NUUDL_SourceUpdated] ,
	[LINK_KUNDE_ID] ,
	[LINK_KUNDENR] ,
	[STILLING] ,
	[FORNAVN] ,
	[EFTERNAVN] ,
	[BUSINESS_NAVN1] ,
	[BUSINESS_NAVN2] ,
	[KUNDE_KATEGORI] ,
	[KUNDE_TYPE] ,
	[CVR_NR] ,
	[FOEDSELSDATO] ,
	[CPR_NR] ,
	[KOEN] ,
	[SIKKERHEDSKODE] ,
	[SLUT_MRK] ,
	[TOTAL_ENGAGEMENT] ,
	[UDLANDS_CVR_NR] ,
	[KUNDE_STATUS] ,
	[POPNAVN] ,
	[POP_FORNAVN] ,
	[POP_EFTERNAVN] ,
	[AENDRINGSSTATUS] ,
	[SIDST_OPD_TSTMP] ,
	[SIDST_OPD_INIT] ,
	[LINK_AARSAG_ID] ,
	[BONUS_FLAG] ,
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
FROM [SourceNuudlLinkit].[LINK_KUNDE_History]
WHERE DWIsCurrent = 1