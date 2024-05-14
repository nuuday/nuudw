
CREATE PROCEDURE [stage].[Transform_Dim_Ticket]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Ticket]

INSERT INTO stage.[Dim_Ticket] WITH (TABLOCK) (TicketKey, TicketCategory, TicketType, TicketStatus)
SELECT 
	id AS TicketKey
	, ticket_category AS TicketCategory
	, ticket_type AS TicketType
	, [status] AS TicketStatus
FROM [sourceNuudlNetCrackerView].[cpmnrmltroubleticket_History]