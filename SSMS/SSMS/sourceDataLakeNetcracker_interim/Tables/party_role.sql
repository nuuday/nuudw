CREATE TABLE [sourceDataLakeNetcracker_interim].[party_role] (
    [id]                             NVARCHAR (500) NULL,
    [active_from]                    NVARCHAR (500) NULL,
    [name]                           NVARCHAR (500) NULL,
    [party_role_type]                NVARCHAR (500) NULL,
    [status]                         NVARCHAR (500) NULL,
    [status_reason]                  NVARCHAR (500) NULL,
    [engaged_party_name]             NVARCHAR (500) NULL,
    [engaged_party_description]      NVARCHAR (500) NULL,
    [engaged_party_id]               NVARCHAR (500) NULL,
    [engaged_party_ref_type]         NVARCHAR (500) NULL,
    [extended_attributes]            NVARCHAR (500) NULL,
    [changed_by]                     NVARCHAR (500) NULL,
    [start_date_time]                NVARCHAR (500) NULL,
    [end_date_time]                  NVARCHAR (500) NULL,
    [billing_synchronization_status] NVARCHAR (500) NULL,
    [idempotency_key]                NVARCHAR (500) NULL,
    [ola_ref]                        NVARCHAR (500) NULL,
    [is_deleted]                     BIT            NULL,
    [last_modified_ts]               NVARCHAR (500) NULL,
    [active_to]                      NVARCHAR (500) NULL,
    [version]                        INT            NULL,
    [DWCreatedDate]                  DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'party_role';

