CREATE TABLE [dim].[ThirdPartyStore] (
    [ThirdPartyStoreID]  INT            IDENTITY (1, 1) NOT NULL,
    [ThirdPartyStoreKey] INT            NULL,
    [StoreID]            INT            NULL,
    [StoreName]          NVARCHAR (100) NULL,
    [DWIsCurrent]        BIT            NOT NULL,
    [DWValidFromDate]    DATETIME2 (0)  NOT NULL,
    [DWValidToDate]      DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]      DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]     DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]        BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ThirdPartyStoreID] ASC),
    CONSTRAINT [NCI_ThirdPartyStore] UNIQUE NONCLUSTERED ([ThirdPartyStoreKey] ASC, [DWValidFromDate] ASC)
);

