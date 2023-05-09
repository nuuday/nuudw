CREATE TABLE [meta].[Environments] (
    [ID]                                       INT            IDENTITY (0, 1) NOT NULL,
    [EnvironmentName]                          NVARCHAR (20)  NULL,
    [DatabaseInstance]                         NVARCHAR (200) NULL,
    [IntegrationServicesInstance]              NVARCHAR (200) NULL,
    [AnalysisServicesMultidimensionalInstance] NVARCHAR (200) NULL,
    [AnalysisServicesTabularInstance]          NVARCHAR (200) NULL
);

