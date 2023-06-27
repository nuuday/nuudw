CREATE TABLE [fact].[ChipperIncidentEvents_Temp] (
    [IncidentEventCustomerIdentifier] NVARCHAR (500) NULL,
    [CalendarID]                      INT            DEFAULT ((-1)) NOT NULL,
    [Legacy_EmployeeID]               INT            DEFAULT ((-1)) NOT NULL,
    [Legacy_CustomerID]               INT            DEFAULT ((-1)) NOT NULL,
    [Legacy_ProductID]                INT            DEFAULT ((-1)) NOT NULL,
    [FAM_SalesChannelID]              INT            DEFAULT ((-1)) NOT NULL,
    [FAM_ChipperStatusID]             INT            DEFAULT ((-1)) NOT NULL,
    [FAM_InfrastructureID]            INT            DEFAULT ((-1)) NOT NULL,
    [FAM_TechnologyID]                INT            DEFAULT ((-1)) NOT NULL,
    [FAM_ChipperIncidentID]           INT            DEFAULT ((-1)) NOT NULL,
    [IncidentCode]                    VARCHAR (15)   NULL,
    [IncidentEventType]               NVARCHAR (500) NULL,
    [IncidentEventEmployeeEmail]      NVARCHAR (100) NULL,
    [IncidentEventLidCode]            NVARCHAR (500) NULL,
    [IncidentEventDay]                DATE           NULL,
    [DWCreatedDate]                   DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]                  DATETIME2 (0)  NOT NULL
);

