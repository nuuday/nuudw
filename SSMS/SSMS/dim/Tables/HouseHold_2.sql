CREATE TABLE [dim].[HouseHold] (
    [HouseHoldID]     INT           IDENTITY (1, 1) NOT NULL,
    [HouseHoldkey]    NVARCHAR (36) NULL,
    [DWIsCurrent]     BIT           NOT NULL,
    [DWValidFromDate] DATETIME2 (0) NOT NULL,
    [DWValidToDate]   DATETIME2 (0) NOT NULL,
    [DWCreatedDate]   DATETIME2 (0) NOT NULL,
    [DWModifiedDate]  DATETIME2 (0) NOT NULL,
    [DWIsDeleted]     BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([HouseHoldID] ASC),
    CONSTRAINT [NCI_HouseHold] UNIQUE NONCLUSTERED ([HouseHoldkey] ASC, [DWValidFromDate] ASC)
);

