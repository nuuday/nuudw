﻿CREATE TABLE [sourceNuudlColumbus].[AFTALE_LID] (
    [NUUDL_SourceCreated]  DATETIME2 (7) NULL,
    [NUUDL_SourceUpdated]  DATETIME2 (7) NULL,
    [ABM_NR]               INT           NULL,
    [ABONNEMENT_ID]        NVARCHAR (26) NULL,
    [AENDRINGSSTATUS]      NVARCHAR (1)  NULL,
    [AFTALE_NR]            INT           NULL,
    [BEM_TEKST]            NVARCHAR (33) NULL,
    [FAST_SPAERRING]       NVARCHAR (1)  NULL,
    [FJERNTELEFON]         NVARCHAR (1)  NULL,
    [FORBIND_ID]           NVARCHAR (26) NULL,
    [GEN_DUT]              NVARCHAR (1)  NULL,
    [KUNDESAG_KD_AFS]      INT           NULL,
    [KUNDESAG_KD_OPR]      INT           NULL,
    [LID]                  NVARCHAR (8)  NULL,
    [LID_STATUS]           NVARCHAR (4)  NULL,
    [MOMSFRI_MRK]          NVARCHAR (1)  NULL,
    [NAVNE_NR]             INT           NULL,
    [NBR_DUT]              NVARCHAR (1)  NULL,
    [OP_SOEGEFELT]         NVARCHAR (35) NULL,
    [ORDRE_NR_AFS]         INT           NULL,
    [ORDRE_NR_OPR]         INT           NULL,
    [PRIS_SOEJLE]          INT           NULL,
    [SIDST_OPD_INIT]       NVARCHAR (8)  NULL,
    [SIDST_OPD_TSTMP]      DATETIME2 (7) NULL,
    [SLUT_DATO]            DATETIME2 (7) NULL,
    [START_DATO]           DATETIME2 (7) NULL,
    [TLF_BOG_OPT_KD]       NVARCHAR (1)  NULL,
    [TRAFIK_OPSM_MRK]      NVARCHAR (1)  NULL,
    [UDSTIL_LID_MRK]       NVARCHAR (1)  NULL,
    [NUUDL_ID]             BIGINT        NOT NULL,
    [NUUDL_ValidFrom]      DATETIME2 (7) NULL,
    [NUUDL_ValidTo]        DATETIME2 (7) NULL,
    [NUUDL_IsCurrent]      BIT           NULL,
    [BIZ_BatchCreatedID]   INT           NULL,
    [BIZ_BatchUpdatedID]   INT           NULL,
    [NUUDL_PKLatest]       BIT           NULL,
    [NUUDL_CuratedBatchID] BIGINT        NULL,
    [DWCreatedDate]        DATETIME2 (7) DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AFTALE_LID] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_AFTALE_LID]
    ON [sourceNuudlColumbus].[AFTALE_LID];

