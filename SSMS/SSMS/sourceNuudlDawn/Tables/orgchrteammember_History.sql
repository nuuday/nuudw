﻿CREATE TABLE [sourceNuudlDawn].[orgchrteammember_History] (
    [contact_medium]                  NVARCHAR (500) NULL,
    [distribution_channel]            NVARCHAR (500) NULL,
    [end_date]                        NVARCHAR (500) NULL,
    [extended_parameters]             NVARCHAR (500) NULL,
    [external_id]                     NVARCHAR (50)  NULL,
    [first_name]                      NVARCHAR (500) NULL,
    [geographic_site]                 NVARCHAR (500) NULL,
    [id]                              NVARCHAR (50)  NULL,
    [idm_roles]                       NVARCHAR (500) NULL,
    [idm_user_id]                     NVARCHAR (50)  NULL,
    [last_name]                       NVARCHAR (500) NULL,
    [name]                            NVARCHAR (500) NULL,
    [op]                              NVARCHAR (500) NULL,
    [position]                        NVARCHAR (500) NULL,
    [skill]                           NVARCHAR (500) NULL,
    [start_date]                      BIGINT         NULL,
    [ts_ms]                           BIGINT         NULL,
    [Snapshot]                        NVARCHAR (500) NULL,
    [Partition_Snapshot]              NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [DWIsCurrent]                     BIT            NULL,
    [DWValidFromDate]                 DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)  NULL,
    [DWCreatedDate]                   DATETIME2 (7)  NULL,
    [DWModifiedDate]                  DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]             BIT            NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)  NULL,
    CONSTRAINT [PK_orgchrteammember_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_orgchrteammember_History]
    ON [sourceNuudlDawn].[orgchrteammember_History];

