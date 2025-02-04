﻿CREATE VIEW [dimView].[Individual] 
AS
SELECT
	[IndividualID]
	,[IndividualKey] AS [IndividualKey]
	,[IndividualFamilyName] AS [IndividualFamilyName]
	,[IndividualGivenName] AS [IndividualGivenName]
	,[IndividualLegalName] AS [IndividualLegalName]
	,[IndividualCountry] AS [IndividualCountry]
	,[IndividualCity] AS [IndividualCity]
	,[IndividualPostcode] AS [IndividualPostcode]
	,[IndividualStreet1] AS [IndividualStreet1]
	,[IndividualStreet2] AS [IndividualStreet2]
	,[IndividualEmail] AS [IndividualEmail]
	,[IndividualPhonenumber] AS [IndividualPhonenumber]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Individual]