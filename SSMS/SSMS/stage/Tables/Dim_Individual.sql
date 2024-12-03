CREATE TABLE [stage].[Dim_Individual] (
    [IndividualKey]         NVARCHAR (36)  NOT NULL,
    [IndividualFamilyName]  NVARCHAR (200) NULL,
    [IndividualGivenName]   NVARCHAR (200) NULL,
    [IndividualLegalName]   NVARCHAR (200) NULL,
    [IndividualCountry]     NVARCHAR (50)  NULL,
    [IndividualCity]        NVARCHAR (50)  NULL,
    [IndividualPostcode]    NVARCHAR (50)  NULL,
    [IndividualStreet1]     NVARCHAR (50)  NULL,
    [IndividualStreet2]     NVARCHAR (50)  NULL,
    [IndividualEmail]       NVARCHAR (200) NULL,
    [IndividualPhonenumber] NVARCHAR (50)  NULL,
    [DWCreatedDate]         DATETIME2 (0)  DEFAULT (sysdatetime()) NOT NULL
);

