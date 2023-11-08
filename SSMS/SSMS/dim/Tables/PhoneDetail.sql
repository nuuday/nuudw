CREATE TABLE [dim].[PhoneDetail] (
    [PhoneDetailID]   INT           IDENTITY (1, 1) NOT NULL,
    [PhoneDetailkey]  NVARCHAR (20) NULL,
    [PhoneStatus]     NVARCHAR (50) NULL,
    [PhoneCategory]   NVARCHAR (50) NULL,
    [PortedIn]        NVARCHAR (1)  NULL,
    [PortedOut]       NVARCHAR (20) NULL,
    [DWIsCurrent]     BIT           NOT NULL,
    [DWValidFromDate] DATETIME2 (0) NOT NULL,
    [DWValidToDate]   DATETIME2 (0) NOT NULL,
    [DWCreatedDate]   DATETIME2 (0) NOT NULL,
    [DWModifiedDate]  DATETIME2 (0) NOT NULL,
    [DWIsDeleted]     BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([PhoneDetailID] ASC),
    CONSTRAINT [NCI_PhoneDetail] UNIQUE NONCLUSTERED ([PhoneDetailkey] ASC, [DWValidFromDate] ASC)
);

