CREATE TABLE [dim].[Legacy_Customer] (
    [Legacy_CustomerID]            INT            IDENTITY (1, 1) NOT NULL,
    [Legacy_CustomerKey]           NVARCHAR (26)  NULL,
    [CustomerCode]                 DECIMAL (12)   NULL,
    [CustomerFirstname]            NVARCHAR (136) NULL,
    [CustomerLastName]             NVARCHAR (136) NULL,
    [CustomerBusinessName1]        NVARCHAR (136) NULL,
    [CustomerBusinessName2]        NVARCHAR (136) NULL,
    [CustomerNameLong]             NVARCHAR (273) NULL,
    [CustomerCategory]             VARCHAR (8)    NULL,
    [CustomerCVRCode]              DECIMAL (36)   NULL,
    [CustomerCVRAbroadCode]        NVARCHAR (72)  NULL,
    [CustomerBirthDate]            DATETIME2 (7)  NULL,
    [CustomerGender]               NVARCHAR (4)   NULL,
    [CustomerStatus]               NVARCHAR (32)  NULL,
    [Legacy_CustomerIsCurrent]     BIT            NULL,
    [Legacy_CustomerValidFromDate] DATETIME2 (7)  NULL,
    [Legacy_CustomerValidToDate]   DATETIME2 (7)  NULL,
    [DWIsCurrent]                  BIT            NOT NULL,
    [DWValidFromDate]              DATETIME2 (0)  NOT NULL,
    [DWValidToDate]                DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]                DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]               DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]                  BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Legacy_CustomerID] ASC),
    CONSTRAINT [NCI_Legacy_Customer] UNIQUE NONCLUSTERED ([Legacy_CustomerKey] ASC, [Legacy_CustomerValidFromDate] ASC)
);




GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Customer', @level2type = N'COLUMN', @level2name = N'Legacy_CustomerKey';

