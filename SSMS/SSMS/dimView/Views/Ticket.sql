CREATE VIEW [dimView].[Ticket] 
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
	
FROM [dim].[Ticket]