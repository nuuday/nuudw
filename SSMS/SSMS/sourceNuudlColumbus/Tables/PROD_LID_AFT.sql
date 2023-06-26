CREATE TABLE [sourceNuudlColumbus].[PROD_LID_AFT] (
    [NUUDL_SourceCreated]  DATETIME2 (7)  NULL,
    [NUUDL_SourceUpdated]  DATETIME2 (7)  NULL,
    [ABONNEMENT_ID]        NVARCHAR (26)  NULL,
    [AENDRINGSSTATUS]      NVARCHAR (1)   NULL,
    [AFSAET_KODE]          NVARCHAR (1)   NULL,
    [ANTAL_PRODUKT]        INT            NULL,
    [ARBITRAER_PRIS]       DECIMAL (9, 2) NULL,
    [B_SLUT_DATO]          DATETIME2 (7)  NULL,
    [FUNKTIONS_NR]         INT            NULL,
    [IDRIFT_MRK]           NVARCHAR (1)   NULL,
    [KUNDE_PRIS_AFT_NO]    INT            NULL,
    [LID_LOEBE_ID]         NVARCHAR (26)  NULL,
    [ORDRE_NR_OPR]         INT            NULL,
    [PROD_LID_AFT_ID]      NVARCHAR (26)  NULL,
    [PRODUKT_ELM_NR]       INT            NULL,
    [PRODUKT_GRP_NR]       INT            NULL,
    [RABAT_LOEB]           DECIMAL (8, 5) NULL,
    [RABAT_LOEB_SAT]       NVARCHAR (1)   NULL,
    [REGNINGS_BEM]         NVARCHAR (35)  NULL,
    [SIDST_OPD_INIT]       NVARCHAR (8)   NULL,
    [SIDST_OPD_TSTMP]      DATETIME2 (7)  NULL,
    [START_DATO]           DATETIME2 (7)  NULL,
    [TEKST_MRK]            NVARCHAR (1)   NULL,
    [UNDERLEV_ID]          NVARCHAR (26)  NULL,
    [NUUDL_ID]             BIGINT         NOT NULL,
    [NUUDL_ValidFrom]      DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]        DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]      BIT            NULL,
    [BIZ_BatchCreatedID]   INT            NULL,
    [BIZ_BatchUpdatedID]   INT            NULL,
    [NUUDL_PKLatest]       BIT            NULL,
    [K_MRK_DATO]           DATETIME2 (7)  NULL,
    [NUUDL_CuratedBatchID] BIGINT         NULL,
    [DWCreatedDate]        DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_PROD_LID_AFT] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_PROD_LID_AFT]
    ON [sourceNuudlColumbus].[PROD_LID_AFT];

