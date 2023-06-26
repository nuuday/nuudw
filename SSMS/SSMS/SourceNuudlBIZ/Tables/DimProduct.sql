﻿CREATE TABLE [SourceNuudlBIZ].[DimProduct] (
    [NUUDL_SourceCreated]           DATETIME2 (7)  NULL,
    [NUUDL_SourceUpdated]           DATETIME2 (7)  NULL,
    [ProductKey]                    INT            NULL,
    [DimEditor_Updated_TS]          DATETIME2 (7)  NULL,
    [DimEditor_Created_TS]          DATETIME2 (7)  NULL,
    [DimEditor_Created_By]          NVARCHAR (250) NULL,
    [ProductID]                     NVARCHAR (20)  NULL,
    [SourceSystem]                  NVARCHAR (10)  NULL,
    [Downstream]                    INT            NULL,
    [ETL_AntalLinier]               INT            NULL,
    [ETL_FlowRelevant]              NVARCHAR (4)   NULL,
    [ETL_ProduktInfo]               NVARCHAR (50)  NULL,
    [ETL_ProduktKobling]            NVARCHAR (50)  NULL,
    [ETL_TekstRelevant]             NVARCHAR (4)   NULL,
    [IsWholesale]                   NVARCHAR (4)   NULL,
    [ProductBrandCategory]          NVARCHAR (50)  NULL,
    [ProductCategory]               NVARCHAR (50)  NULL,
    [ProductChange]                 NVARCHAR (20)  NULL,
    [ProductChangeCategory]         NVARCHAR (30)  NULL,
    [ProductMainCategory]           NVARCHAR (50)  NULL,
    [ProductName]                   NVARCHAR (200) NULL,
    [ProductNetworkTechnology]      NVARCHAR (50)  NULL,
    [ProductSubCategory]            NVARCHAR (50)  NULL,
    [ProductTargetCustomer]         NVARCHAR (50)  NULL,
    [ProductTransmissionTechnology] NVARCHAR (50)  NULL,
    [ProductType]                   NVARCHAR (50)  NULL,
    [SalesEffectiveDate]            DATETIME2 (7)  NULL,
    [SalesExperiationDate]          DATETIME2 (7)  NULL,
    [ServiceType]                   NVARCHAR (50)  NULL,
    [SourceCreatedDate]             DATETIME2 (7)  NULL,
    [SourceEffectiveDate]           DATETIME2 (7)  NULL,
    [SourceExpirationDate]          DATETIME2 (7)  NULL,
    [SourceUpdatedBy]               NVARCHAR (50)  NULL,
    [SourceUpdatedDate]             DATETIME2 (7)  NULL,
    [Upstream]                      INT            NULL,
    [NUUDL_ID]                      BIGINT         NOT NULL,
    [NUUDL_ValidFrom]               DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                 DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]               BIT            NULL,
    [BIZ_BatchCreatedID]            INT            NULL,
    [BIZ_BatchUpdatedID]            INT            NULL,
    [NUUDL_PKLatest]                BIT            NULL,
    [SAF_Attr]                      NVARCHAR (50)  NULL,
    [ETL_SAFFlowrelevant]           NVARCHAR (50)  NULL,
    [ETL_SAFFlowrelevantDate]       NVARCHAR (50)  NULL,
    [Niv1]                          INT            NULL,
    [Niv2]                          INT            NULL,
    [Niv3]                          INT            NULL,
    [Niv4]                          INT            NULL,
    [ProductSubCategory2]           NVARCHAR (50)  NULL,
    [BellisPrioritet]               INT            NULL,
    [Bemaerkning]                   NVARCHAR (250) NULL,
    [CallDirectionFrom]             NVARCHAR (20)  NULL,
    [CallDirectionTo]               NVARCHAR (20)  NULL,
    [Landekode]                     NVARCHAR (20)  NULL,
    [Source_Created_By]             NVARCHAR (250) NULL,
    [Source_Updated_By]             NVARCHAR (250) NULL,
    [TrafficAddon]                  NVARCHAR (20)  NULL,
    [Volumetype]                    NVARCHAR (16)  NULL,
    [BundleType]                    NVARCHAR (25)  NULL,
    [Technology]                    NVARCHAR (15)  NULL,
    [ProductWeight]                 INT            NULL,
    [NUUDL_CuratedBatchID]          BIGINT         NULL,
    [DWCreatedDate]                 DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DimProduct] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_DimProduct]
    ON [SourceNuudlBIZ].[DimProduct];

