﻿CREATE TABLE [sourceNuudlDawn].[cpmnrmltroubleticketrelatedentityref_History] (
    [id]                              NVARCHAR (50)   NULL,
    [name]                            NVARCHAR (500)  NULL,
    [op]                              NVARCHAR (500)  NULL,
    [role]                            NVARCHAR (500)  NULL,
    [trouble_ticket_id]               NVARCHAR (50)   NULL,
    [ts_ms]                           BIGINT          NULL,
    [type]                            NVARCHAR (500)  NULL,
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
    CONSTRAINT [PK_cpmnrmltroubleticketrelatedentityref_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cpmnrmltroubleticketrelatedentityref_History]
    ON [sourceNuudlDawn].[cpmnrmltroubleticketrelatedentityref_History];



