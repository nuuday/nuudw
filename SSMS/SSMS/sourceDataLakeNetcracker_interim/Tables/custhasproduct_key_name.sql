CREATE TABLE [sourceDataLakeNetcracker_interim].[custhasproduct_key_name] (
    [customer_ref]  NVARCHAR (500) NULL,
    [product_seq]   INT            NULL,
    [name]          NVARCHAR (500) NULL,
    [DWCreatedDate] DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'custhasproduct_key_name';

