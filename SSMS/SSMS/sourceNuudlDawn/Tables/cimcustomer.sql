﻿CREATE TABLE [sourceNuudlDawn].[cimcustomer] (
    [active_from]                          DATETIME2 (7)   NULL,
    [billing_data]                         NVARCHAR (MAX)  NULL,
    [billing_synchronization_status]       NVARCHAR (4000) NULL,
    [brand_id]                             NVARCHAR (50)   NULL,
    [changed_by]                           NVARCHAR (MAX)  NULL,
    [customer_category_id]                 NVARCHAR (50)   NULL,
    [customer_number]                      NVARCHAR (4000) NULL,
    [customer_since]                       DATETIME2 (7)   NULL,
    [end_date_time]                        DATETIME2 (7)   NULL,
    [engaged_party_description]            NVARCHAR (4000) NULL,
    [engaged_party_id]                     NVARCHAR (50)   NULL,
    [engaged_party_name]                   NVARCHAR (4000) NULL,
    [engaged_party_ref_type]               NVARCHAR (4000) NULL,
    [extended_attributes]                  NVARCHAR (MAX)  NULL,
    [external_id]                          NVARCHAR (50)   NULL,
    [id]                                   NVARCHAR (50)   NULL,
    [idempotency_key]                      NVARCHAR (4000) NULL,
    [last_nps_survey_ref]                  NVARCHAR (4000) NULL,
    [name]                                 NVARCHAR (4000) NULL,
    [net_promoter_score]                   NVARCHAR (4000) NULL,
    [ola_ref]                              NVARCHAR (MAX)  NULL,
    [org_chart_ref]                        NVARCHAR (MAX)  NULL,
    [portfolio]                            NVARCHAR (4000) NULL,
    [start_date_time]                      DATETIME2 (7)   NULL,
    [status]                               NVARCHAR (4000) NULL,
    [status_reason]                        NVARCHAR (4000) NULL,
    [ts_ms]                                BIGINT          NULL,
    [lsn]                                  BIGINT          NULL,
    [op]                                   NVARCHAR (4000) NULL,
    [extended_attributes_brandName]        NVARCHAR (4000) NULL,
    [extended_attributes_employeeBrand]    NVARCHAR (4000) NULL,
    [extended_attributes_employeeId]       NVARCHAR (4000) NULL,
    [extended_attributes_migration_date]   NVARCHAR (4000) NULL,
    [extended_attributes_migration_phase]  NVARCHAR (4000) NULL,
    [extended_attributes_migration_source] NVARCHAR (4000) NULL,
    [extended_attributes_migrationFlag]    NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                      BIT             NULL,
    [NUUDL_ValidFrom]                      DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                        DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]                 INT             NULL,
    [NUUDL_CuratedProcessedTimestamp]      NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                      BIT             NULL,
    [NUUDL_DeleteType]                     NVARCHAR (4000) NULL,
    [NUUDL_ID]                             BIGINT          NOT NULL,
    [NUUDL_IsLatest]                       BIT             NULL,
    [DWCreatedDate]                        DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimcustomer] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimcustomer]
    ON [sourceNuudlDawn].[cimcustomer];





