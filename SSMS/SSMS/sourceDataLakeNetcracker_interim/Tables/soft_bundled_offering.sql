CREATE TABLE [sourceDataLakeNetcracker_interim].[soft_bundled_offering] (
    [localized_name]           NVARCHAR (500) NULL,
    [id]                       NVARCHAR (500) NULL,
    [external_id]              NVARCHAR (500) NULL,
    [name]                     NVARCHAR (500) NULL,
    [extended_parameters]      NVARCHAR (500) NULL,
    [eligibility_condition_id] NVARCHAR (500) NULL,
    [cdc_revision_id]          NVARCHAR (500) NULL,
    [DWCreatedDate]            DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'soft_bundled_offering';

