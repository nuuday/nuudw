CREATE TABLE [fact].[ChipperIncidents] (
    [CalendarID]                                  INT            DEFAULT ((-1)) NOT NULL,
    [CalendarPickedID]                            INT            DEFAULT ((-1)) NOT NULL,
    [CalendarDerivedID]                           INT            DEFAULT ((-1)) NOT NULL,
    [CalendarCancelledID]                         INT            DEFAULT ((-1)) NOT NULL,
    [CalendarClosedID]                            INT            DEFAULT ((-1)) NOT NULL,
    [Legacy_EmployeeID]                           INT            DEFAULT ((-1)) NOT NULL,
    [Legacy_CustomerID]                           INT            DEFAULT ((-1)) NOT NULL,
    [Legacy_ProductID]                            INT            DEFAULT ((-1)) NOT NULL,
    [FAM_SalesChannelID]                          INT            DEFAULT ((-1)) NOT NULL,
    [FAM_ChipperStatusID]                         INT            DEFAULT ((-1)) NOT NULL,
    [FAM_ChipperIncidentID]                       INT            DEFAULT ((-1)) NOT NULL,
    [FAM_InfrastructureID]                        INT            DEFAULT ((-1)) NOT NULL,
    [FAM_TechnologyID]                            INT            DEFAULT ((-1)) NOT NULL,
    [FAM_OpenIncidentsGroupID]                    INT            DEFAULT ((-1)) NOT NULL,
    [FAM_OpenIncidentsGroupHandleID]              INT            DEFAULT ((-1)) NOT NULL,
    [FAM_OpenIncidentsGroupInstallationToErrorID] INT            DEFAULT ((-1)) NOT NULL,
    [IncidentCode]                                NVARCHAR (55)  NULL,
    [IncidentLidCode]                             NVARCHAR (55)  NULL,
    [IncidentProduct]                             NVARCHAR (55)  NULL,
    [IncidentCreated]                             INT            NULL,
    [IncidentClosed]                              INT            NULL,
    [IncidentPicked]                              INT            NULL,
    [IncidentDerived]                             INT            NULL,
    [IncidentCancelled]                           INT            NULL,
    [IncidentResponseTime]                        INT            NULL,
    [IncidentDaysOpen]                            INT            NULL,
    [IncidentDaysToHandle]                        INT            NULL,
    [IncidentRepeating3Days]                      INT            NULL,
    [IncidentRepeating14Days]                     INT            NULL,
    [TechnologyInstalled]                         NVARCHAR (55)  NULL,
    [DaysFromInstallationToError]                 INT            NULL,
    [PercentOfIncidents3DaysFromInstallation]     DECIMAL (7, 4) NULL,
    [PercentOfIncidents14DaysFromInstallation]    DECIMAL (7, 4) NULL,
    [DWCreatedDate]                               DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]                              DATETIME2 (0)  NOT NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ChipperIncidents]
    ON [fact].[ChipperIncidents];

