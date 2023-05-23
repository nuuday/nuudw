CREATE TABLE [sourceDataLakeNetcracker_interim].[prod_catalog_bundled_offer] (
    [product_catalog_id]       NVARCHAR (500) NULL,
    [soft_bundled_offering_id] NVARCHAR (500) NULL,
    [cdc_revision_id]          NVARCHAR (500) NULL,
    [DWCreatedDate]            DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'prod_catalog_bundled_offer';

