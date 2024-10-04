CREATE TABLE [sourceNuudlDawn].[cimpartyroleassociation] (
    [active_from]                     DATETIME2 (7)   NULL,
    [association_name]                NVARCHAR (4000) NULL,
    [association_role]                NVARCHAR (4000) NULL,
    [changed_by]                      NVARCHAR (MAX)  NULL,
    [id]                              NVARCHAR (50)   NULL,
    [id_from]                         NVARCHAR (4000) NULL,
    [id_to]                           NVARCHAR (4000) NULL,
    [ref_type_from]                   NVARCHAR (4000) NULL,
    [ref_type_to]                     NVARCHAR (4000) NULL,
    [ts_ms]                           BIGINT          NULL,
    [lsn]                             BIGINT          NULL,
    [op]                              NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimpartyroleassociation] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimpartyroleassociation]
    ON [sourceNuudlDawn].[cimpartyroleassociation];





