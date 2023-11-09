CREATE TABLE [stage].[Dim_Address] (
    [AddressKey]    NVARCHAR (300) NULL,
    [Street1]       NVARCHAR (50)  NULL,
    [Street2]       NVARCHAR (50)  NULL,
    [Postcode]      NVARCHAR (50)  NULL,
    [City]          NVARCHAR (50)  NULL,
    [DWCreatedDate] DATETIME       NOT NULL
);

