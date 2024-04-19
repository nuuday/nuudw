CREATE TABLE [sourceNuudlNetCracker].[cpmnrmltroubleticketrelatedentityref] (
    [id]                                   NVARCHAR (36)  NULL,
    [type]                                 NVARCHAR (300) NULL,
    [name]                                 NVARCHAR (300) NULL,
    [role]                                 NVARCHAR (300) NULL,
    [trouble_ticket_id]                    NVARCHAR (36)  NULL,
    [is_deleted]                           BIT            NULL,
    [last_modified_ts]                     DATETIME2 (7)  NULL,
    [NUUDL_ValidFrom]                      DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                        DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                      BIT            NULL,
    [NUUDL_ID]                             BIGINT         NOT NULL,
    [NUUDL_StandardizedProcessedTimestamp] DATETIME2 (7)  NULL,
    [NUUDL_CuratedBatchID]                 INT            NULL,
    [NUUDL_CuratedProcessedTimestamp]      NVARCHAR (300) NULL,
    [NUUDL_CuratedSourceFilename]          NVARCHAR (300) NULL,
    [DWCreatedDate]                        DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cpmnrmltroubleticketrelatedentityref] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cpmnrmltroubleticketrelatedentityref]
    ON [sourceNuudlNetCracker].[cpmnrmltroubleticketrelatedentityref];

