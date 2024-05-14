CREATE TABLE [stage].[Dim_Ticket] (
    [TicketKey]      NVARCHAR (36)  NULL,
    [TicketCategory] NVARCHAR (100) NULL,
    [TicketType]     NVARCHAR (50)  NULL,
    [TicketStatus]   NVARCHAR (50)  NULL,
    [DWCreatedDate]  DATETIME2 (0)  DEFAULT (sysdatetime()) NULL
);

