
CREATE PROCEDURE [stage].[Transform_Dim_FAM_ChipperIncident]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_FAM_ChipperIncident]

DROP TABLE IF EXISTS #Comments
SELECT
	Comments.id,
	LEFT( Comments.Comments, LEN( Comments.Comments ) - 1 ) AS "Comments"
INTO #Comments
FROM (
	SELECT DISTINCT
		ST2.id,
		(
			SELECT
				ST1.[comments.text] + '... ' AS [text()]
			FROM sourceNuuDataChipperView.[ChipperTicketsComments_History] ST1
			WHERE
				ST1.id = ST2.id
			ORDER BY
				ST1.id
			FOR XML PATH (''), TYPE
		)
		.value( 'text()[1]', 'nvarchar(max)' ) [Comments]
	FROM sourceNuuDataChipperView.[ChipperTicketsComments_History] ST2
) AS Comments

DROP TABLE IF EXISTS #tags
SELECT
	tags.id,
	LEFT( tags.tags, LEN( tags.tags ) - 1 ) AS "tags"
INTO #tags
FROM (
	SELECT DISTINCT
		ST2.id,
		(
			SELECT
				'"' + ST1.tags + '", ' AS [text()]
			FROM sourceNuuDataChipperView.[ChipperTicketsTags_History] ST1
			WHERE
				ST1.id = ST2.id
			ORDER BY
				ST1.id
			FOR XML PATH (''), TYPE
		)
		.value( 'text()[1]', 'nvarchar(max)' ) [tags]
	FROM sourceNuuDataChipperView.[ChipperTicketsTags_History] ST2
) AS tags

INSERT INTO stage.[Dim_FAM_ChipperIncident] WITH (TABLOCK) ( FAM_ChipperIncidentKey, AssigneeCreated, AssigneePicked, AssigneeResolved, startdate, CreatedDate, UpdatedDate, ReportedDate, ResolvedDate, PickedDate, ClosedDate, CustomerEmailAdress, CustomerPhoneNumber, CustomerContactName, CustomerIDCode, impact, Description, type, ItemLidCode, SLAIDCode, status, subject, ProductIDCode, IncidentCode, Comments, Tags, OutageIncidentCode, DWCreatedDate )
SELECT DISTINCT
	tickets.[id] AS FAM_ChipperIncidentKey,
	assignee.IncidentTicketCreated AS AssigneeCreated,
	assignee.IncidentTicketPicked AS AssigneePicked,
	assignee.IncidentTicketResolved AS AssigneeResolved,
	CONVERT( DATE, [issue.start] ) AS StartDate,
	CONVERT( DATE, [created] ) AS CreatedDate,
	CONVERT( DATE, [updated] ) AS UpdatedDate,
	CONVERT( DATE, [reported] ) AS ReportedDate,
	CONVERT( DATE, [resolved] ) AS ResolvedDate,
	CONVERT( DATE, piv2.IncidentTicketPicked ) AS PickedDate,
	CONVERT( DATE, piv2.IncidentTicketClosed ) AS ClosedDate,
	[customer.contact.channels.email.address] AS CustomerEmailAdress,
	[customer.contact.channels.phone.number] AS CustomerPhoneNumber,
	[customer.contact.name] AS CustomerContactName,
	[customer.id] AS CustomerIDCode,
	[Impact] AS Impact,
	[issue.description] AS Description,
	[issue.type] AS Type,
	[item.lid] AS ItemLidCode,
	[sla.id] AS SLAIDCode,
	[Status] AS Status,
	[Subject] AS Subject,
	[product.id] AS ProductIDCode,
	tickets.[id] AS IncidentCode,
	#Comments.[Comments] AS Comments,
	#tags.[Tags] AS Tags,
	tickets.outageid AS OutageIncidentCode,
	GETDATE() AS DWCreatedDate
FROM sourceNuuDataChipperView.[ChipperTicketsTickets_History] tickets
LEFT JOIN #Comments
	ON #Comments.id = tickets.id
LEFT JOIN #tags
	ON #tags.id = tickets.id
LEFT JOIN (

	SELECT
		id,
		IncidentTicketPicked,
		IncidentTicketClosed
	FROM (
		SELECT
			id,
			[eventLog.eventType],
			[eventLog.timestamp]
		FROM sourceNuuDataChipperView.[ChipperTicketsEventLog_History]
	) ec
	PIVOT
	(
	MAX( [eventLog.timestamp] )
	FOR [eventLog.eventType] IN (IncidentTicketPicked, IncidentTicketClosed)
	) piv

) piv2
	ON piv2.id = tickets.id

LEFT JOIN (

	SELECT
		id,
		IncidentTicketCreated,
		IncidentTicketPicked,
		IncidentTicketResolved
	FROM (
		SELECT
			id,
			COALESCE( [eventLog.source.userId], [eventLog.source.error.userId] ) AS UserID,
			[eventLog.eventType]
		FROM sourceNuuDataChipperView.[ChipperTicketsEventLog_History]
	) ab
	PIVOT
	(
	MAX( UserID )
	FOR [eventLog.eventType] IN (IncidentTicketCreated, IncidentTicketPicked, IncidentTicketResolved)
	) piv3

) assignee
	ON assignee.id = tickets.id