CREATE VIEW cubeView_FAM.[Dim Chipper Last Updated] 
AS
SELECT DISTINCT
	CONVERT( DATE, DWCreatedDate ) AS ChipperLastUpdated
FROM [fact].[ChipperIncidents]