CREATE TABLE [stage].[Dim_PhoneDetail] (
    [PhoneDetailkey] NVARCHAR (20) NULL,
    [PhoneStatus]    NVARCHAR (50) NULL,
    [PhoneCategory]  NVARCHAR (50) NULL,
    [PortedIn]       NVARCHAR (1)  NULL,
    [PortedOut]      NVARCHAR (20) NULL,
    [DWCreatedDate]  DATETIME      NOT NULL
);

