CREATE TABLE [masterdata].[ProductTypeMapping_History] (
    [ID]              INT            NOT NULL,
    [Producttype_org] NVARCHAR (100) NULL,
    [Producttype]     NVARCHAR (100) NULL,
    [ValidFrom]       DATETIME2 (7)  NOT NULL,
    [ValidTo]         DATETIME2 (7)  NOT NULL
);


GO
CREATE CLUSTERED INDEX [ix_ProductTypeMapping_History]
    ON [masterdata].[ProductTypeMapping_History]([ValidTo] ASC, [ValidFrom] ASC) WITH (DATA_COMPRESSION = PAGE);

