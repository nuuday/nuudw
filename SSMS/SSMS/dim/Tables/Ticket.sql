CREATE TABLE [dim].[Ticket] (
    [TicketID]        INT            IDENTITY (1, 1) NOT NULL,
    [TicketKey]       NVARCHAR (36)  NULL,
    [TicketCategory]  NVARCHAR (100) NULL,
    [TicketType]      NVARCHAR (50)  NULL,
    [TicketStatus]    NVARCHAR (50)  NULL,
    [DWIsCurrent]     BIT            NOT NULL,
    [DWValidFromDate] DATETIME2 (0)  NOT NULL,
    [DWValidToDate]   DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]   DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]  DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]     BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([TicketID] ASC),
    CONSTRAINT [NCI_Ticket] UNIQUE NONCLUSTERED ([TicketKey] ASC, [DWValidFromDate] ASC)
);

