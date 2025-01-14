CREATE TABLE [dim].[Individual] (
    [IndividualID]          INT            IDENTITY (1, 1) NOT NULL,
    [IndividualKey]         NVARCHAR (36)  NULL,
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
    [DWIsCurrent]           BIT            NOT NULL,
    [DWValidFromDate]       DATETIME2 (0)  NOT NULL,
    [DWValidToDate]         DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]         DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]        DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]           BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IndividualID] ASC),
    CONSTRAINT [NCI_Individual] UNIQUE NONCLUSTERED ([IndividualKey] ASC, [DWValidFromDate] ASC)
);

