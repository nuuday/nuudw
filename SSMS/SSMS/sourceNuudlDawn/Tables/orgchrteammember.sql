CREATE TABLE [sourceNuudlDawn].[orgchrteammember] (
    [contact_medium]                  NVARCHAR (MAX)  NULL,
    [distribution_channel]            NVARCHAR (MAX)  NULL,
    [end_date]                        DATETIME2 (7)   NULL,
    [extended_parameters]             NVARCHAR (MAX)  NULL,
    [external_id]                     NVARCHAR (50)   NULL,
    [first_name]                      NVARCHAR (4000) NULL,
    [geographic_site]                 NVARCHAR (4000) NULL,
    [id]                              NVARCHAR (50)   NULL,
    [idm_roles]                       NVARCHAR (4000) NULL,
    [idm_user_id]                     NVARCHAR (50)   NULL,
    [last_name]                       NVARCHAR (4000) NULL,
    [name]                            NVARCHAR (4000) NULL,
    [position]                        NVARCHAR (4000) NULL,
    [skill]                           NVARCHAR (4000) NULL,
    [start_date]                      DATETIME2 (7)   NULL,
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
    CONSTRAINT [PK_orgchrteammember] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_orgchrteammember]
    ON [sourceNuudlDawn].[orgchrteammember];





