
CREATE VIEW [cubeView_PRX].[DimTicket] 
AS
SELECT
	[TicketID]
	,[TicketKey] AS [TicketKey]
	,[TicketCategory] AS [TicketCategory]
	,[TicketType] AS [TicketType]
	,[TicketStatus] AS [TicketStatus]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]	
FROM [dimView].[Ticket]