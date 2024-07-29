
CREATE VIEW [martView_PRX].[DimTicket]
AS
SELECT 	[TicketID],	[TicketKey],	[TicketCategory],	[TicketType],	[TicketStatus]
FROM [dimView].[Ticket]