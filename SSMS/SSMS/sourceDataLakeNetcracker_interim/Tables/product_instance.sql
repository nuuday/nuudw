CREATE TABLE [sourceDataLakeNetcracker_interim].[product_instance] (
    [id]                   NVARCHAR (500) NULL,
    [active_from]          NVARCHAR (500) NULL,
    [active_to]            NVARCHAR (500) NULL,
    [version]              BIGINT         NULL,
    [schema_version]       NVARCHAR (500) NULL,
    [state]                NVARCHAR (500) NULL,
    [offering_id]          NVARCHAR (500) NULL,
    [customer_id]          NVARCHAR (500) NULL,
    [customer_category_id] NVARCHAR (500) NULL,
    [root_id]              NVARCHAR (500) NULL,
    [accountref_id]        NVARCHAR (500) NULL,
    [start_date]           NVARCHAR (500) NULL,
    [termination_date]     NVARCHAR (500) NULL,
    [DWCreatedDate]        DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'product_instance';

