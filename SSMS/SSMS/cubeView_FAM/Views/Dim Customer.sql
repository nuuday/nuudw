
CREATE VIEW cubeView_FAM.[Dim Customer]
AS
SELECT
	[Legacy_CustomerID],
	[Legacy Customer Key],
	[Customer Code],
	[Customer Firstname],
	[Customer Last Name],
	[Customer Business Name 1],
	[Customer Business Name 2],
	[Customer Name Long],
	[Customer Category],
	[Customer CVR Code],
	[Customer CVR Abroad Code],
	[Customer Birth Date],
	[Customer Gender],
	[Customer Status]
FROM [dimView].[Legacy Customer]