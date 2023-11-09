CREATE TABLE [sourceNuudlNetCracker].[cimpartyroleassociation] (
    [id]                       NVARCHAR (36)  NULL,
    [ref_type_from]            NVARCHAR (300) NULL,
    [id_from]                  NVARCHAR (300) NULL,
    [ref_type_to]              NVARCHAR (300) NULL,
    [id_to]                    NVARCHAR (300) NULL,
    [association_role]         NVARCHAR (300) NULL,
    [association_name]         NVARCHAR (300) NULL,
    [active_from]              DATETIME2 (7)  NULL,
    [changed_by_json_userId]   NVARCHAR (36)  NULL,
    [changed_by_json_userName] NVARCHAR (300) NULL,
    [is_deleted]               BIT            NULL,
    [last_modified_ts]         DATETIME2 (7)  NULL,
    [active_to]                NVARCHAR (300) NULL,
    [version]                  INT            NULL,
    [is_current]               BIT            NULL,
    [NUUDL_ValidFrom]          DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]            DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]          BIT            NULL,
    [NUUDL_ID]                 BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]     BIGINT         NULL,
    [DWCreatedDate]            DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimpartyroleassociation] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimpartyroleassociation]
    ON [sourceNuudlNetCracker].[cimpartyroleassociation];

