CREATE TABLE [stage].[Dim_Individual] (
    [IndividualKey]         NVARCHAR (36)  NOT NULL,
    [IndividualFamilyName]  NVARCHAR (200) NOT NULL,
    [IndividualGivenName]   NVARCHAR (200) NOT NULL,
    [IndividualLegalName]   NVARCHAR (200) NOT NULL,
    [IndividualCountry]     NVARCHAR (50)  NOT NULL,
    [IndividualCity]        NVARCHAR (50)  NOT NULL,
    [IndividualPostcode]    NVARCHAR (50)  NOT NULL,
    [IndividualStreet1]     NVARCHAR (50)  NOT NULL,
    [IndividualStreet2]     NVARCHAR (50)  NOT NULL,
    [IndividualEmail]       NVARCHAR (200) NOT NULL,
    [IndividualPhonenumber] NVARCHAR (50)  NOT NULL,
    [DWCreatedDate]         DATETIME2 (0)  DEFAULT (sysdatetime()) NOT NULL
);

