
CREATE PROCEDURE [stage].[Transform_Fact_ChipperIncidentEvents]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Fact_ChipperIncidentEvents]

/* Infrastructure for Fiber Logic */
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #AFT_LID --Finde kun relevante Abonnements ID'er ud fra LID, så vi kan ramme indexet på [sourceNuudlColumbusView].[PROD_LID_AFT_History], da det er en kæmpe tabel

CREATE TABLE #AFT_LID (
	LID			  NVARCHAR(50),
	START_DATO	  DATETIME,
	ABONNEMENT_ID NVARCHAR(50)
	)

INSERT INTO #AFT_LID ( LID, START_DATO, ABONNEMENT_ID )
SELECT DISTINCT
	ah.LID,
	ah.START_DATO,
	ah.ABONNEMENT_ID
FROM [sourceNuudlColumbusView].[AFTALE_LID_History] ah
WHERE
	1 = 1
	AND ah.LID IN
	(
		SELECT
			[item.lid]
		FROM sourceNuuDataChipperView.[ChipperTicketsTickets_History]
		WHERE
			DWIsCurrent = 1
			AND [item.lid] LIKE '%EF%'
	)


DROP TABLE IF EXISTS #InfratructureProducts --Slår Produkter op, der indikere en infrastruktur i [sourceNuudlColumbusView].[PROD_LID_AFT_History]. Bruger #AFT_LID til at ramme index

CREATE TABLE #InfratructureProducts (
	ABONNEMENT_ID NVARCHAR(50),
	Product		  NVARCHAR(50)
	)


INSERT INTO #InfratructureProducts ( ABONNEMENT_ID, Product )
SELECT DISTINCT
	ABONNEMENT_ID,
	CONCAT( 'C001', (REPLICATE( '0', 2 - LEN( PRODUKT_GRP_NR ) ) + CAST( PRODUKT_GRP_NR AS NVARCHAR )), (REPLICATE( '0', 3 - LEN( PRODUKT_ELM_NR ) ) + CAST( PRODUKT_ELM_NR AS NVARCHAR )), (REPLICATE( '0', 2 - LEN( FUNKTIONS_NR ) ) + CAST( FUNKTIONS_NR AS NVARCHAR )) ) Product
FROM [sourceNuudlColumbusView].[PROD_LID_AFT_History]
WHERE
	CONCAT( 'C001', (REPLICATE( '0', 2 - LEN( PRODUKT_GRP_NR ) ) + CAST( PRODUKT_GRP_NR AS NVARCHAR )), (REPLICATE( '0', 3 - LEN( PRODUKT_ELM_NR ) ) + CAST( PRODUKT_ELM_NR AS NVARCHAR )), (REPLICATE( '0', 2 - LEN( FUNKTIONS_NR ) ) + CAST( FUNKTIONS_NR AS NVARCHAR )) )
	IN ('C0010766087', 'C0010766866', 'C0010766865', 'C0010766864', 'C0010766868', 'C0010766869', 'C0010766879', 'C0010766867')
	AND START_DATO <> '0001-01-03 00:00:00.0000000' --Ligner DEFAULT eller FEJL. Giver Dublet på forskellige infrastruktur på samme abonnement
	AND ABONNEMENT_ID IN
	(SELECT ABONNEMENT_ID FROM #AFT_LID)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO stage.[Fact_ChipperIncidentEvents] WITH (TABLOCK) ( [CalendarKey], [Legacy_EmployeeKey], [FAM_SalesChannelKey], [FAM_ChipperStatusKey], [Legacy_CustomerKey], [FAM_InfrastructureKey], [FAM_TechnologyKey], [Legacy_ProductKey], [FAM_ChipperIncidentKey], [IncidentCode], [IncidentEventType], [IncidentEventEmployeeEmail], [IncidentEventLidCode], [IncidentEventCustomerIdentifier], [IncidentEventDay] )
SELECT
	--KEYS
	CONVERT( DATE, CONVERT( VARCHAR(10), el.[eventLog.timestamp], 112 ) ) AS CalendarKey,
	e.EmployeeID AS EmployeeKey,
	CONCAT( UPPER( SUBSTRING( tags.tags, 1, 1 ) ), LOWER( SUBSTRING( tags.tags, 2, 10 ) ) ) AS SalesChannelKey,
	t.status AS ChipperStatusKey,
	SUBSTRING( tech.CustomerKey, 1, 19 ) + REPLACE( SUBSTRING( tech.CustomerKey, 20, 26 ), ':', '.' ) AS CustomerKey -- CustomerKey er lavet med DataType: DateTime - Som anvendes i dim.Customer.
	,
	CASE
		WHEN SUBSTRING( t.[item.lid], 1, 2 ) IN ('YL', 'YC', 'YK', 'EM') THEN 'TDC NET INFRASTRUKTUR'
		ELSE p.ProductName
	END AS InfrastructureKey,
	tech.Technology AS TechnologyKey,
	CASE
		WHEN t.[product.id] LIKE '%SP%' THEN 'C001' + [dbo].[udf_GetNumeric]( t.[product.id] )
		ELSE NULL
	END AS ProductKey,
	t.id AS ChipperIncidentKey
	--ATTRIBUTES
	,
	el.id AS IncidentCode,
	el.[eventLog.eventType] AS IncidentEventType,
	COALESCE( [eventLog.source.userId], [eventLog.source.error.userId] ) AS IncidentEventEmployeeEmail,
	t.[item.lid] AS IncidentEventLidCode,
	t.[customer.id] AS IncidentEventCustomerIdentifier,
	CONVERT( DATE, el.[eventLog.timestamp] ) AS IncidentEventDay
FROM sourceNuuDataChipperView.[ChipperTicketsEventLog_History] el
LEFT JOIN ( --TODO: Dubletter på mails og medarbejder ID'er, da man godt kan tildele en anden person en mail, der har eksisteret før. Sørg for dato styring. Eksempelvis 'jone@yousee.dk'
	SELECT
		Email,
		EmployeeID,
		ROW_NUMBER() OVER (PARTITION BY Email ORDER BY SRC_DW_Valid_FROM DESC) RN
	FROM [sourceCubusMasterData].[DimEmployee]
	WHERE
		1 = 1
		AND NULLIF( Email, '' ) IS NOT NULL --UNDERSØG OLSK@yousee.dk, da denne har to medarbejderID'er - Samme mail givet til to forskellige personer. Dog ikke på samme tid
) e
	ON e.Email = COALESCE( [eventLog.source.userId], [eventLog.source.error.userId] )--Konvertere mails til MedarbejderKey over til dim.Employee
		AND e.RN = 1
--Getusers i Chipper er ikke opdateret, så vi skal i nogle tilfælde benytte error, hvor error output er den mail, som ikke eksisterer i Chipper Getusers

LEFT JOIN (
	SELECT DISTINCT
		id,
		tags
	FROM sourceNuuDataChipperView.[ChipperTicketsTags_History]
	WHERE
		DWIsCurrent = 1
		AND tags IN ('yousee', 'erhverv')
) tags
	ON tags.id = el.id

LEFT JOIN sourceNuuDataChipperView.[ChipperTicketsTickets_History] t
	ON t.id = el.id
		AND t.DWIsCurrent = 1


LEFT JOIN (
	SELECT
		LID,
		Product,
		ROW_NUMBER() OVER (PARTITION BY LID ORDER BY START_DATO DESC) RN --Få tilfælde af forskellige infrastruktur på samme LID. Tager den tættest på, hvornår en Incident er oprettet
	FROM #AFT_LID a

INNER JOIN #InfratructureProducts b
	ON b.ABONNEMENT_ID = a.ABONNEMENT_ID

INNER JOIN sourceNuuDataChipperView.[ChipperTicketsTickets_History] c
	ON c.[item.lid] = a.LID
		AND CONVERT( DATE, a.START_DATO ) <= CONVERT( DATE, c.created )
		AND c.DWIsCurrent = 1
) ifp
	ON ifp.LID = t.[item.lid]
		AND ifp.RN = 1



LEFT JOIN SourceNuudlBIZView.[DimProduct_History] p
	ON p.ProductID = ifp.Product
		AND p.DWIsCurrent = 1

LEFT JOIN (
	SELECT DISTINCT
		(SUBSTRING( LinkKundeID, 1, 10 ) + ' ' + REPLACE( SUBSTRING( LinkKundeID, 12, 19 ), '.', ':' )) AS CustomerKey,
		LID,
		Technology
	FROM [SourceCubus31PCTI].[BUI_915_Customers_CU]
) tech
	ON t.[item.lid] = tech.LID

WHERE
	el.DWIsCurrent = 1