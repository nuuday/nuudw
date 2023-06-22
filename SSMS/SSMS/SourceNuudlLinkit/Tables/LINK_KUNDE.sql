﻿CREATE TABLE [SourceNuudlLinkit].[LINK_KUNDE] (
    [NUUDL_SourceCreated]  DATETIME2 (7) NULL,
    [NUUDL_SourceUpdated]  DATETIME2 (7) NULL,
    [LINK_KUNDE_ID]        NVARCHAR (26) NULL,
    [LINK_KUNDENR]         NVARCHAR (12) NULL,
    [STILLING]             NVARCHAR (34) NULL,
    [FORNAVN]              NVARCHAR (34) NULL,
    [EFTERNAVN]            NVARCHAR (34) NULL,
    [BUSINESS_NAVN1]       NVARCHAR (34) NULL,
    [BUSINESS_NAVN2]       NVARCHAR (34) NULL,
    [KUNDE_KATEGORI]       NVARCHAR (12) NULL,
    [KUNDE_TYPE]           INT           NULL,
    [CVR_NR]               NVARCHAR (10) NULL,
    [FOEDSELSDATO]         DATETIME2 (7) NULL,
    [CPR_NR]               NVARCHAR (10) NULL,
    [KOEN]                 NVARCHAR (1)  NULL,
    [SIKKERHEDSKODE]       NVARCHAR (10) NULL,
    [SLUT_MRK]             NVARCHAR (1)  NULL,
    [TOTAL_ENGAGEMENT]     NVARCHAR (1)  NULL,
    [UDLANDS_CVR_NR]       NVARCHAR (18) NULL,
    [KUNDE_STATUS]         NVARCHAR (8)  NULL,
    [POPNAVN]              NVARCHAR (68) NULL,
    [POP_FORNAVN]          NVARCHAR (34) NULL,
    [POP_EFTERNAVN]        NVARCHAR (34) NULL,
    [AENDRINGSSTATUS]      NVARCHAR (1)  NULL,
    [SIDST_OPD_TSTMP]      DATETIME2 (7) NULL,
    [SIDST_OPD_INIT]       NVARCHAR (8)  NULL,
    [LINK_AARSAG_ID]       NVARCHAR (26) NULL,
    [BONUS_FLAG]           NVARCHAR (1)  NULL,
    [NUUDL_ID]             BIGINT        NOT NULL,
    [NUUDL_ValidFrom]      DATETIME2 (7) NULL,
    [NUUDL_ValidTo]        DATETIME2 (7) NULL,
    [NUUDL_IsCurrent]      BIT           NULL,
    [BIZ_BatchCreatedID]   INT           NULL,
    [BIZ_BatchUpdatedID]   INT           NULL,
    [NUUDL_PKLatest]       BIT           NULL,
    [NUUDL_CuratedBatchID] BIGINT        NULL,
    [DWCreatedDate]        DATETIME2 (7) DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_LINK_KUNDE] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_LINK_KUNDE]
    ON [SourceNuudlLinkit].[LINK_KUNDE];

