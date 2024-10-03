﻿CREATE TABLE [sourceNuudlDawn].[cimpartyroleassociation_History] (
    [active_from]                     DATETIME2 (7)   NULL,
    [association_name]                NVARCHAR (500)  NULL,
    [association_role]                NVARCHAR (500)  NULL,
    [changed_by]                      NVARCHAR (MAX)  NULL,
    [id]                              NVARCHAR (50)   NULL,
    [id_from]                         NVARCHAR (500)  NULL,
    [id_to]                           NVARCHAR (500)  NULL,
    [op]                              NVARCHAR (500)  NULL,
    [ref_type_from]                   NVARCHAR (500)  NULL,
    [ref_type_to]                     NVARCHAR (500)  NULL,
    [ts_ms]                           BIGINT          NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500)  NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [DWIsCurrent]                     BIT             NULL,
    [DWValidFromDate]                 DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)   NULL,
    [DWCreatedDate]                   DATETIME2 (7)   NULL,
    [DWModifiedDate]                  DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]             BIT             NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)   NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    CONSTRAINT [PK_cimpartyroleassociation_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimpartyroleassociation_History]
    ON [sourceNuudlDawn].[cimpartyroleassociation_History];



