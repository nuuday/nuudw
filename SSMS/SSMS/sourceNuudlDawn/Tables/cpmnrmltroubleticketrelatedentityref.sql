CREATE TABLE [sourceNuudlDawn].[cpmnrmltroubleticketrelatedentityref] (
    [id]                              NVARCHAR (50)  NULL,
    [name]                            NVARCHAR (500) NULL,
    [op]                              NVARCHAR (500) NULL,
    [role]                            NVARCHAR (500) NULL,
    [trouble_ticket_id]               NVARCHAR (50)  NULL,
    [ts_ms]                           BIGINT         NULL,
    [type]                            NVARCHAR (500) NULL,
    [Snapshot]                        NVARCHAR (500) NULL,
    [Partition_Snapshot]              NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cpmnrmltroubleticketrelatedentityref] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cpmnrmltroubleticketrelatedentityref]
    ON [sourceNuudlDawn].[cpmnrmltroubleticketrelatedentityref];

