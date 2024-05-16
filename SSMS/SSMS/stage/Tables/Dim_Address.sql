CREATE TABLE [stage].[Dim_Address] (
    [AddressKey]    NVARCHAR (300) NULL,
    [Street1]       NVARCHAR (50)  NULL,
    [Street2]       NVARCHAR (50)  NULL,
    [Postcode]      NVARCHAR (50)  NULL,
    [City]          NVARCHAR (50)  NULL,
    [Floor]         NVARCHAR (10)  NULL,
    [Suite]         NVARCHAR (10)  NULL,
    [NAMID]         NVARCHAR (10)  NULL,
    [DWCreatedDate] DATETIME2 (0)  DEFAULT (sysdatetime()) NULL
);



