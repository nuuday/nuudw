CREATE VIEW cubeView_FAM.[Fact Chipper Incident Events]
AS
SELECT
	[CalendarID],
	[Legacy_EmployeeID] AS [EmployeeID],
	[Legacy_CustomerID] AS [CustomerID],
	[Legacy_ProductID] AS [ProductID],
	[FAM_SalesChannelID] AS [SalesChannelID],
	[FAM_ChipperStatusID] AS [ChipperStatusID],
	[FAM_InfrastructureID] AS [InfrastructureID],
	[FAM_TechnologyID] AS [TechnologyID],
	[FAM_ChipperIncidentID] AS [ChipperIncidentID],
	[IncidentCode],
	[IncidentEventType],
	[IncidentEventEmployeeEmail],
	[IncidentEventLidCode],
	[IncidentEventDay]
FROM [factView].[Chipper Incident Events]