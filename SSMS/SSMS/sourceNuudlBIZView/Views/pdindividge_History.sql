

CREATE VIEW [sourceNuudlBIZView].[pdindividge_History]
AS
SELECT 
	[NUUDL_SourceCreated] ,
	[NUUDL_SourceUpdated] ,
	[FIRMA] ,
	[ENHED] ,
	[VIRKNR] ,
	[LOENNR] ,
	[LOEBENR] ,
	[STATUS] ,
	[ANUMMER] ,
	[EMAIL] ,
	[STEDNR] ,
	[AONR] ,
	[KONTORFORK] ,
	[KONTORNAVN] ,
	[FYSADR] ,
	[POSTADR] ,
	[STIL_KODE] ,
	[INITIALER] ,
	[NAVN] ,
	[FORNAVN] ,
	[MELLEMNAVN] ,
	[EFTERNAVN] ,
	[ADRESSE] ,
	[ADRLIN_1] ,
	[ADRLIN_2] ,
	[ADRLIN_3] ,
	[POSTNR] ,
	[KOEN] ,
	[ANS_DATO] ,
	[AFG_DATO] ,
	[FOD_DATO] ,
	[START_ORLOV] ,
	[SLUT_ORLOV] ,
	[OMRAADE] ,
	[TLFLOK] ,
	[TLFDIR] ,
	[TLFMOB] ,
	[TLFALT] ,
	[TLFFAX] ,
	[TLFOPS] ,
	[TLFUDL] ,
	[TJEGREN] ,
	[KATEGORI] ,
	[AFLFORM] ,
	[TILHOER] ,
	[ARBSTEDKD] ,
	[AENDRET] ,
	[OPDATERET] ,
	[NORMTID] ,
	[TRGRUPPE] ,
	[BANKREGNR] ,
	[BANKKONTONR] ,
	[FAGGRUPPE] ,
	[NUUDL_ID] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[BIZ_BatchCreatedID] ,
	[BIZ_BatchUpdatedID] ,
	[NUUDL_PKLatest] ,
	[NUUDL_BaseSourceFilename] ,
	[NUUDL_BaseBatchID] ,
	[NUUDL_BaseProcessedTimestamp] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlBIZ].[pdindividge_History]
WHERE DWIsCurrent = 1 AND [NUUDL_IsCurrent] = 1