CREATE TABLE [stage].[Fact_ChipperIncidentEvents] (
    [IncidentEventCustomerIdentifier] NVARCHAR (500)  NULL,
    [CalendarKey]                     DATE            NULL,
    [Legacy_EmployeeKey]              NVARCHAR (11)   NULL,
    [Legacy_CustomerKey]              NVARCHAR (4000) NULL,
    [Legacy_ProductKey]               VARCHAR (260)   NULL,
    [FAM_SalesChannelKey]             NVARCHAR (11)   NOT NULL,
    [FAM_ChipperStatusKey]            NVARCHAR (500)  NULL,
    [FAM_InfrastructureKey]           NVARCHAR (200)  NULL,
    [FAM_TechnologyKey]               NVARCHAR (15)   NULL,
    [FAM_ChipperIncidentKey]          NVARCHAR (500)  NULL,
    [IncidentCode]                    VARCHAR (15)    NOT NULL,
    [IncidentEventType]               NVARCHAR (500)  NOT NULL,
    [IncidentEventEmployeeEmail]      NVARCHAR (100)  NULL,
    [IncidentEventLidCode]            NVARCHAR (500)  NULL,
    [IncidentEventDay]                DATE            NULL
);

