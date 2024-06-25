CREATE TABLE [SourceNuudlNAM].[nam] (
    [sub_address_id]                  INT            NOT NULL,
    [sub_address_floor]               NVARCHAR (500) NULL,
    [sub_address_suite]               NVARCHAR (500) NULL,
    [sub_address_dar_id]              NVARCHAR (36)  NULL,
    [sub_address_mad_id]              NVARCHAR (36)  NULL,
    [sub_address_kvhx_id]             NVARCHAR (36)  NULL,
    [sub_address_official]            BIT            NULL,
    [sub_address_deleted]             BIT            NULL,
    [address_id]                      INT            NULL,
    [address_street_name]             NVARCHAR (500) NULL,
    [address_street_no]               NVARCHAR (500) NULL,
    [address_street_no_suffix]        NVARCHAR (500) NULL,
    [address_postcode]                NVARCHAR (500) NULL,
    [address_city]                    NVARCHAR (500) NULL,
    [address_municipality]            NVARCHAR (500) NULL,
    [address_district]                NVARCHAR (500) NULL,
    [address_region]                  NVARCHAR (500) NULL,
    [address_street_code]             NVARCHAR (500) NULL,
    [address_region_code]             NVARCHAR (500) NULL,
    [address_dar_id]                  NVARCHAR (36)  NULL,
    [address_mad_id]                  NVARCHAR (36)  NULL,
    [address_kvhx_id]                 NVARCHAR (36)  NULL,
    [sub_address_kvhx_id_2]           NVARCHAR (500) NULL,
    [address_official]                BIT            NULL,
    [address_deleted]                 BIT            NULL,
    [NUUDL_BaseSourceFilename]        NVARCHAR (500) NULL,
    [NUUDL_BaseBatchID]               INT            NULL,
    [NUUDL_BaseProcessedTimestamp]    NVARCHAR (500) NULL,
    [Snapshot]                        NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_CuratedSourceFilename]     NVARCHAR (500) NULL,
    [DWCreatedDate]                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_nam] PRIMARY KEY NONCLUSTERED ([sub_address_id] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nam]
    ON [SourceNuudlNAM].[nam];

