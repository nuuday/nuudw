CREATE TABLE [dim].[OrderEvent] (
    [OrderEventID]    INT           IDENTITY (1, 1) NOT NULL,
    [OrderEventKey]   NVARCHAR (3)  NULL,
    [OrderEventName]  NVARCHAR (50) NULL,
    [SourceEventName] NVARCHAR (50) NULL,
    [DWIsCurrent]     BIT           NOT NULL,
    [DWValidFromDate] DATETIME2 (0) NOT NULL,
    [DWValidToDate]   DATETIME2 (0) NOT NULL,
    [DWCreatedDate]   DATETIME2 (0) NOT NULL,
    [DWModifiedDate]  DATETIME2 (0) NOT NULL,
    [DWIsDeleted]     BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([OrderEventID] ASC),
    CONSTRAINT [NCI_OrderEvent] UNIQUE NONCLUSTERED ([OrderEventKey] ASC, [DWValidFromDate] ASC)
);

