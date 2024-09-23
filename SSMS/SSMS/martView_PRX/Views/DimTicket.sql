
CREATE VIEW [martView_PRX].[DimTicket]
AS
SELECT 
	[TicketID],
	[TicketKey],
	[TicketCategory],
	[TicketType],
	[TicketStatus],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Ticket]