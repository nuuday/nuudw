﻿
CREATE VIEW cubeView_FAM.[Fact Chipper Incidents]
AS
SELECT 
	[CalendarID],
	[CalendarPickedID],
	[CalendarDerivedID],
	[CalendarCancelledID],
	[CalendarClosedID],
	[Legacy_EmployeeID],
	[Legacy_CustomerID],
	[Legacy_ProductID],
	[FAM_SalesChannelID],
	[FAM_ChipperStatusID],
	[FAM_ChipperIncidentID],
	[FAM_InfrastructureID],
	[FAM_TechnologyID],
	[FAM_OpenIncidentsGroupID],
	[FAM_OpenIncidentsGroupHandleID],
	[FAM_OpenIncidentsGroupInstallationToErrorID],
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