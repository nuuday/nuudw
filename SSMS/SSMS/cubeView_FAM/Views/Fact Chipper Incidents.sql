﻿
CREATE VIEW cubeView_FAM.[Fact Chipper Incidents]
AS
SELECT 
	[CalendarID],
	[CalendarPickedID],
	[CalendarDerivedID],
	[CalendarCancelledID],
	[CalendarClosedID],
	[Legacy_EmployeeID] AS [EmployeeID],
	[Legacy_CustomerID] AS [CustomerID],
	[Legacy_ProductID] AS [ProductID],
	[FAM_SalesChannelID] AS [SalesChannelID],
	[FAM_ChipperStatusID] AS [ChipperStatusID],
	[FAM_ChipperIncidentID] AS [ChipperIncidentID],
	[FAM_InfrastructureID] AS [InfrastructureID],
	[FAM_TechnologyID] AS [TechnologyID],
	[FAM_OpenIncidentsGroupID] AS [OpenIncidentsGroupID],
	[FAM_OpenIncidentsGroupHandleID] AS [OpenIncidentsGroupHandleID],
	[FAM_OpenIncidentsGroupInstallationToErrorID] AS [OpenIncidentsGroupInstallationToErrorID],
	[IncidentCode],
	[IncidentLidCode],
	[IncidentProduct],
	[IncidentCreated],
	[IncidentClosed],
	[IncidentPicked],
	[IncidentDerived],
	[IncidentCancelled],
	[IncidentResponseTime],
	[IncidentDaysOpen],
	[IncidentDaysToHandle],
	[IncidentRepeating3Days],
	[IncidentRepeating14Days],
	[TechnologyInstalled],
	[DaysFromInstallationToError],
	[PercentOfIncidents3DaysFromInstallation],
	[PercentOfIncidents14DaysFromInstallation]
FROM [factView].[Chipper Incidents]