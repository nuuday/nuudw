CREATE TABLE [stage].[Dim_PhoneDetail] (
    [PhoneDetailkey]           NVARCHAR (20)  NOT NULL,
    [PhoneStatus]              NVARCHAR (50)  NULL,
    [PhoneCategory]            NVARCHAR (50)  NULL,
    [PortedIn]                 NVARCHAR (1)   NULL,
    [PortedOut]                NVARCHAR (20)  NULL,
    [PortedInFrom]             NVARCHAR (100) NULL,
    [PortedOutTo]              NVARCHAR (100) NULL,
    [PhoneDetailValidFromDate] DATETIME2 (0)  NOT NULL,
    [PhoneDetailValidToDate]   DATETIME2 (0)  NOT NULL,
    [PhoneDetailIsCurrent]     BIT            NOT NULL,
    [DWCreatedDate]            DATETIME2 (0)  DEFAULT (sysdatetime()) NOT NULL
);





