
CREATE VIEW cubeView_FAM.[Dim Chipper Incident]
AS

SELECT
	[FAM_ChipperIncidentID],
	[FAM Chipper Incident Key],
	[Start Date],
	[Created Date],
	[Updated Date],
	[Reported Date],
	[Resolved Date],
	[Customer Email Adress],
	[Customer Phone Number],
	[Customer Contact Name],
	[Customer ID Code],
	[Impact],
	[Description],
	[Type],
	[Item Lid Code],
	[SLAID Code],
	[Status],
	[Subject],
	[Product ID Code],
	[Comments],
	[Tags],
	[Picked Date],
	[Closed Date],
	[Assignee Created],
	[Assignee Picked],
	[Assignee Resolved],
	[Incident Code],
	[Outage Incident Code]
FROM [dimView].[FAM Chipper Incident]