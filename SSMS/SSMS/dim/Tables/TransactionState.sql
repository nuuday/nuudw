CREATE TABLE [dim].[TransactionState] (
    [TransactionStateID]   INT           IDENTITY (1, 1) NOT NULL,
    [TransactionStateKey]  NVARCHAR (1)  NULL,
    [TransactionStateName] NVARCHAR (20) NULL,
    [DWIsCurrent]          BIT           NOT NULL,
    [DWValidFromDate]      DATETIME2 (0) NOT NULL,
    [DWValidToDate]        DATETIME2 (0) NOT NULL,
    [DWCreatedDate]        DATETIME2 (0) NOT NULL,
    [DWModifiedDate]       DATETIME2 (0) NOT NULL,
    [DWIsDeleted]          BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([TransactionStateID] ASC),
    CONSTRAINT [NCI_TransactionState] UNIQUE NONCLUSTERED ([TransactionStateKey] ASC, [DWValidFromDate] ASC)
);

