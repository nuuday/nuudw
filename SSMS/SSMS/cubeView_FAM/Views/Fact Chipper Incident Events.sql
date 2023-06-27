CREATE VIEW cubeView_FAM.[Fact Chipper Incident Events]
AS
SELECT
	[CalendarID],
	[Legacy_EmployeeID],
	[Legacy_CustomerID],
	[Legacy_ProductID],
	[FAM_SalesChannelID],
	[FAM_ChipperStatusID],
	[FAM_InfrastructureID],
	[FAM_TechnologyID],
	[FAM_ChipperIncidentID],
	[IncidentCode],
	[IncidentEventType],
	[IncidentEventEmployeeEmail],
	[IncidentEventLidCode],
	[IncidentEventDay]
FROM [factView].[Chipper Incident Events]