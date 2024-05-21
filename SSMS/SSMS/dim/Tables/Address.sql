CREATE TABLE [dim].[Address] (
    [AddressID]       INT            IDENTITY (1, 1) NOT NULL,
    [AddressKey]      NVARCHAR (300) NULL,
    [Street1]         NVARCHAR (50)  NULL,
    [Street2]         NVARCHAR (50)  NULL,
    [Postcode]        NVARCHAR (50)  NULL,
    [City]            NVARCHAR (50)  NULL,
    [Floor]           NVARCHAR (10)  NULL,
    [Suite]           NVARCHAR (10)  NULL,
    [NAMID]           NVARCHAR (10)  NULL,
    [DarId]           NVARCHAR (32)  NULL,
    [MadId]           NVARCHAR (32)  NULL,
    [KvhxId]          NVARCHAR (20)  NULL,
    [DWIsCurrent]     BIT            NOT NULL,
    [DWValidFromDate] DATETIME2 (0)  NOT NULL,
    [DWValidToDate]   DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]   DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]  DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]     BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([AddressID] ASC),
    CONSTRAINT [NCI_Address] UNIQUE NONCLUSTERED ([AddressKey] ASC, [DWValidFromDate] ASC)
);





