
CREATE VIEW [martView_PRX].[DimIndividual] 
AS
SELECT
	[IndividualID]
	, [IndividualKey]
	, [IndividualFamilyName]
	, [IndividualGivenName]
	, [IndividualLegalName]
	,[IndividualCountry]
	, [IndividualCity]
	, [IndividualPostcode]
	, [IndividualStreet1]
	, [IndividualStreet2]
	, [IndividualEmail]
	,[IndividualPhonenumber]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dimView].[Individual]