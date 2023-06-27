CREATE TABLE [stage].[Dim_Legacy_Customer] (
    [Legacy_CustomerKey]           NVARCHAR (26)  NOT NULL,
    [CustomerCode]                 DECIMAL (12)   NULL,
    [CustomerFirstname]            NVARCHAR (136) NULL,
    [CustomerLastName]             NVARCHAR (136) NULL,
    [CustomerBusinessName1]        NVARCHAR (136) NULL,
    [CustomerBusinessName2]        NVARCHAR (136) NULL,
    [CustomerNameLong]             NVARCHAR (273) NULL,
    [CustomerCategory]             VARCHAR (8)    NOT NULL,
    [CustomerCVRCode]              DECIMAL (36)   NULL,
    [CustomerCVRAbroadCode]        NVARCHAR (72)  NULL,
    [CustomerBirthDate]            DATETIME2 (7)  NULL,
    [CustomerGender]               NVARCHAR (4)   NULL,
    [CustomerStatus]               NVARCHAR (32)  NULL,
    [Legacy_CustomerIsCurrent]     BIT            NULL,
    [Legacy_CustomerValidFromDate] DATETIME2 (7)  NOT NULL,
    [Legacy_CustomerValidToDate]   DATETIME2 (7)  NULL,
    [DWCreatedDate]                DATETIME       NOT NULL
);

