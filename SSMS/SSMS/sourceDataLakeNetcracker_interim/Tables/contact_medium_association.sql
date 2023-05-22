CREATE TABLE [sourceDataLakeNetcracker_interim].[contact_medium_association] (
    [id]                NVARCHAR (500) NULL,
    [ref_id]            NVARCHAR (500) NULL,
    [ref_type]          NVARCHAR (500) NULL,
    [contact_medium_id] NVARCHAR (500) NULL,
    [changed_by]        NVARCHAR (500) NULL,
    [active_from]       NVARCHAR (500) NULL,
    [is_deleted]        BIT            NULL,
    [last_modified_ts]  NVARCHAR (500) NULL,
    [active_to]         NVARCHAR (500) NULL,
    [version]           INT            NULL,
    [DWCreatedDate]     DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'contact_medium_association';

