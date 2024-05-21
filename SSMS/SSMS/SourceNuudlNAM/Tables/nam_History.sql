CREATE TABLE [SourceNuudlNAM].[nam_History] (
    [sub_address_id]                  INT            NULL,
    [sub_address_floor]               NVARCHAR (300) NULL,
    [sub_address_suite]               NVARCHAR (300) NULL,
    [sub_address_dar_id]              NVARCHAR (36)  NULL,
    [sub_address_mad_id]              NVARCHAR (36)  NULL,
    [sub_address_kvhx_id]             NVARCHAR (36)  NULL,
    [sub_address_official]            BIT            NULL,
    [sub_address_deleted]             BIT            NULL,
    [address_id]                      INT            NULL,
    [address_street_name]             NVARCHAR (300) NULL,
    [address_street_no]               NVARCHAR (300) NULL,
    [address_street_no_suffix]        NVARCHAR (300) NULL,
    [address_postcode]                NVARCHAR (300) NULL,
    [address_city]                    NVARCHAR (300) NULL,
    [address_municipality]            NVARCHAR (300) NULL,
    [address_district]                NVARCHAR (300) NULL,
    [address_region]                  NVARCHAR (300) NULL,
    [address_street_code]             NVARCHAR (300) NULL,
    [address_region_code]             NVARCHAR (300) NULL,
    [address_dar_id]                  NVARCHAR (36)  NULL,
    [address_mad_id]                  NVARCHAR (36)  NULL,
    [address_kvhx_id]                 NVARCHAR (36)  NULL,
    [sub_address_kvhx_id_2]           NVARCHAR (300) NULL,
    [address_official]                BIT            NULL,
    [address_deleted]                 BIT            NULL,
    [NUUDL_BaseSourceFilename]        NVARCHAR (300) NULL,
    [NUUDL_BaseBatchID]               INT            NULL,
    [NUUDL_BaseProcessedTimestamp]    NVARCHAR (300) NULL,
    [Snapshot]                        NVARCHAR (300) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (300) NULL,
    [NUUDL_CuratedSourceFilename]     NVARCHAR (300) NULL,
    [DWIsCurrent]                     BIT            NULL,
    [DWValidFromDate]                 DATETIME2 (7)  NULL,
    [DWValidToDate]                   DATETIME2 (7)  NULL,
    [DWCreatedDate]                   DATETIME2 (7)  NULL,
    [DWModifiedDate]                  DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]             BIT            NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)  NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nam_History]
    ON [SourceNuudlNAM].[nam_History];

