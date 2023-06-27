
CREATE PROCEDURE [stage].[Transform_Fact_ChipperIncidents]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Fact_ChipperIncidents]


/* START_DATO From AFTALE_LID */
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #AFTLID

CREATE TABLE #AFTLID (
	LID				 NVARCHAR(50),
	START_DATO		 DATE,
	DWValidFromDate DATETIME,
	DWValidToDate	 DATETIME
	)

INSERT INTO #AFTLID ( LID, START_DATO, DWValidFromDate, DWValidToDate )
SELECT DISTINCT
	a.LID,
	a.START_DATO,
	a.DWValidFromDate,
	IIF( DATEDIFF( DAY, a.DWValidToDate, LEAD( a.DWValidFromDate ) OVER (PARTITION BY a.LID ORDER BY a.DWValidFromDate) ) = 0, DATEADD( DAY, -1, a.DWValidToDate ), a.DWValidToDate ) --Hvis perioder overlapper
FROM [sourceNuudlColumbusView].[AFTALE_LID_History] a
INNER JOIN sourceNuuDataChipperView.[ChipperTicketsTickets_History] t
	ON --Frasortere irrelevante LID for at optimere forespørgsel
		t.[item.lid] = a.LID
		AND t.DWIsCurrent = 1
WHERE
	1 = 1
	AND LID_STATUS IN ('A')
	AND AENDRINGSSTATUS <> 'H'


DROP TABLE IF EXISTS #LIDSTART

CREATE TABLE #LIDSTART (
	LID			 NVARCHAR(50),
	START_DATO	 DATE,
	IncidentCode NVARCHAR(50)
	)

INSERT INTO #LIDSTART ( LID, START_DATO, IncidentCode )
SELECT DISTINCT
	LID,
	START_DATO,
	t.ID AS IncidentCode
FROM #AFTLID a
INNER JOIN sourceNuuDataChipperView.[ChipperTicketsTickets_History] t
	ON --Forudsætter, at oprettelse af et incident, skal være mellem LID'ets aktive periode. Ellers bør det ikke kunne fejlmeldes
		t.[item.lid] = a.LID
		AND CONVERT( DATE, t.created ) BETWEEN CONVERT( DATE, a.DWValidFromDate ) AND CONVERT( DATE, a.DWValidToDate )
		AND t.DWIsCurrent = 1

/* Total ActiveCustomers */
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #TotalActiveCustomers

CREATE TABLE #TotalActiveCustomers (
	TotalCustomers INT,
	START_DATO		DATE

	)

INSERT INTO #TotalActiveCustomers ( START_DATO, TotalCustomers )

SELECT
	SUBSTRING( CAST( START_DATO AS NVARCHAR ), 1, 10 ) AS START_DATO,
	COUNT( DISTINCT LID ) AS TotalActiveCustomers
FROM [sourceNuudlColumbusView].[AFTALE_LID_History]
WHERE
	LID_STATUS IN ('A')
	AND AENDRINGSSTATUS <> 'H'
GROUP BY START_DATO
ORDER BY
	START_DATO DESC

/* PercentOfIncidents3DaysFromInstallation Logic */
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #Customers3Days

CREATE TABLE #Customers3Days (
	[item.lid]			NVARCHAR(55),
	START_DATO			DATE,
	TicketCreated		DATE,
	NumberOfIncidents INT
	)

INSERT INTO #Customers3Days ( [item.lid], START_DATO, TicketCreated, NumberOfIncidents )
SELECT DISTINCT
	[item.lid],
	SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ) AS START_DATO,
	CONVERT( DATE, t.created ) AS TicketCreated,
	1 AS NumberOfIncidents
FROM sourceNuuDataChipperView.[ChipperTicketsTickets_History] t
LEFT JOIN [sourceNuudlColumbusView].[AFTALE_LID_History] lid
	ON t.[item.lid] = lid.lid
WHERE
	DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), CONVERT( DATE, t.created ) ) BETWEEN 0 AND 3

DROP TABLE IF EXISTS #PercentOfIncidents3DaysFromInstallation
SELECT
	PercentOfIncidents3DaysFromInstallation.START_DATO,
	CAST( SUM( CAST( PercentOfIncidents3DaysFromInstallation.NumberOfIncidents AS FLOAT ) ) / MAX( CAST( #TotalActiveCustomers.TotalCustomers AS FLOAT ) ) AS DECIMAL(7, 4) ) AS PercentOfIncidents3DaysFromInstallation
INTO #PercentOfIncidents3DaysFromInstallation
FROM #Customers3Days PercentOfIncidents3DaysFromInstallation
LEFT JOIN #TotalActiveCustomers
	ON PercentOfIncidents3DaysFromInstallation.START_DATO = #TotalActiveCustomers.START_DATO
GROUP BY PercentOfIncidents3DaysFromInstallation.START_DATO

/* PercentOfIncidents14DaysFromInstallation Logic */
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #Customers14Days

CREATE TABLE #Customers14Days (
	[item.lid]			NVARCHAR(55),
	START_DATO			DATE,
	TicketCreated		DATE,
	NumberOfIncidents INT
	)

INSERT INTO #Customers14Days ( [item.lid], START_DATO, TicketCreated, NumberOfIncidents )

SELECT DISTINCT
	[item.lid],
	SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ) AS START_DATO,
	CONVERT( DATE, t.created ) AS TicketCreated,
	1 AS NumberOfIncidents
FROM sourceNuuDataChipperView.[ChipperTicketsTickets_History] t
LEFT JOIN [sourceNuudlColumbusView].[AFTALE_LID_History] lid
	ON t.[item.lid] = lid.lid
WHERE
	DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), CONVERT( DATE, t.created ) ) BETWEEN 0 AND 14

DROP TABLE IF EXISTS #PercentOfIncidents14DaysFromInstallation
SELECT
	PercentOfIncidents14DaysFromInstallation.START_DATO,
	CAST( SUM( CAST( PercentOfIncidents14DaysFromInstallation.NumberOfIncidents AS FLOAT ) ) / MAX( CAST( #TotalActiveCustomers.TotalCustomers AS FLOAT ) ) AS DECIMAL(7, 4) ) AS PercentOfIncidents14DaysFromInstallation
INTO #PercentOfIncidents14DaysFromInstallation
FROM #Customers14Days PercentOfIncidents14DaysFromInstallation
LEFT JOIN #TotalActiveCustomers
	ON PercentOfIncidents14DaysFromInstallation.START_DATO = #TotalActiveCustomers.START_DATO
GROUP BY PercentOfIncidents14DaysFromInstallation.START_DATO

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
DROP TABLE IF EXISTS #Incidents

CREATE TABLE #Incidents (
	CalendarKey										  DATE,
	EmployeeKey										  NVARCHAR(55),
	SalesChannelKey								  NVARCHAR(55),
	ChipperStatusKey								  NVARCHAR(55),
	CustomerKey										  NVARCHAR(55),
	InfrastructureKey								  NVARCHAR(55),
	TechnologyKey									  NVARCHAR(55),
	ProductKey										  NVARCHAR(55),
	OpenIncidentsGroupKey						  NVARCHAR(55),
	OpenIncidentsGroupHandleKey				  NVARCHAR(55),
	OpenIncidentsGroupInstallationToErrorKey NVARCHAR(55),
	ChipperIncidentKey							  NVARCHAR(55),
	IncidentCode									  NVARCHAR(55),
	IncidentLidCode								  NVARCHAR(55),
	IncidentProduct								  NVARCHAR(55),
	TechnologyInstalled							  NVARCHAR(55),
	IncidentCreated								  INT,
	IncidentClosed									  INT,
	IncidentPicked									  INT,
	IncidentDerived								  INT,
	IncidentCancelled								  INT,
	CalendarClosedKey								  DATE,
	CalendarPickedKey								  DATE,
	CalendarDerivedKey							  DATE,
	CalendarCancelledKey							  DATE,
	IncidentResponseTime							  INT,
	IncidentDaysOpen								  INT,
	IncidentDaysToHandle							  INT,
	DaysFromInstallationToError				  INT,
	PercentOfIncidents3DaysFromInstallation  DECIMAL(7, 4),
	PercentOfIncidents14DaysFromInstallation DECIMAL(7, 4)
	)

INSERT INTO #Incidents ( CalendarKey, EmployeeKey, SalesChannelKey, ChipperStatusKey, CustomerKey, InfrastructureKey, TechnologyKey, ProductKey, OpenIncidentsGroupKey, OpenIncidentsGroupHandleKey, OpenIncidentsGroupInstallationToErrorKey, ChipperIncidentKey, IncidentCode, IncidentLidCode, IncidentProduct, TechnologyInstalled, IncidentCreated, IncidentClosed, IncidentPicked, IncidentDerived, IncidentCancelled, CalendarClosedKey, CalendarPickedKey, CalendarDerivedKey, CalendarCancelledKey, IncidentResponseTime, IncidentDaysOpen, IncidentDaysToHandle, DaysFromInstallationToError, PercentOfIncidents3DaysFromInstallation, PercentOfIncidents14DaysFromInstallation )
SELECT
	--KEYS
	CONVERT( DATE, t.created ) AS CalendarKey,
	e.EmployeeID AS EmployeeKey,
	CONCAT( UPPER( SUBSTRING( tags.tags, 1, 1 ) ), LOWER( SUBSTRING( tags.tags, 2, 10 ) ) ) AS SalesChannelKey,
	t.Status AS ChipperStatusKey,
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
	CASE
		WHEN IIF( t.Status = 'OPEN', DATEDIFF( DAY, t.created, GETDATE() ), NULL ) BETWEEN 0 AND 3 THEN 1
		WHEN IIF( t.Status = 'OPEN', DATEDIFF( DAY, t.created, GETDATE() ), NULL ) BETWEEN 4 AND 7 THEN 2
		WHEN IIF( t.Status = 'OPEN', DATEDIFF( DAY, t.created, GETDATE() ), NULL ) BETWEEN 8 AND 14 THEN 3
		WHEN IIF( t.Status = 'OPEN', DATEDIFF( DAY, t.created, GETDATE() ), NULL ) BETWEEN 15 AND 28 THEN 4
		WHEN IIF( t.Status = 'OPEN', DATEDIFF( DAY, t.created, GETDATE() ), NULL ) BETWEEN 29 AND 35 THEN 5
		WHEN IIF( t.Status = 'OPEN', DATEDIFF( DAY, t.created, GETDATE() ), NULL ) BETWEEN 36 AND 49 THEN 6
		WHEN IIF( t.Status = 'OPEN', DATEDIFF( DAY, t.created, GETDATE() ), NULL ) > 49 THEN 7
	END AS OpenIncidentsGroupKey,
	CASE
		WHEN DATEDIFF( DAY, t.created, piv2.IncidentTicketClosed ) BETWEEN 0 AND 3 THEN 1
		WHEN DATEDIFF( DAY, t.created, piv2.IncidentTicketClosed ) BETWEEN 4 AND 7 THEN 2
		WHEN DATEDIFF( DAY, t.created, piv2.IncidentTicketClosed ) BETWEEN 8 AND 14 THEN 3
		WHEN DATEDIFF( DAY, t.created, piv2.IncidentTicketClosed ) BETWEEN 15 AND 28 THEN 4
		WHEN DATEDIFF( DAY, t.created, piv2.IncidentTicketClosed ) BETWEEN 29 AND 35 THEN 5
		WHEN DATEDIFF( DAY, t.created, piv2.IncidentTicketClosed ) BETWEEN 36 AND 49 THEN 6
		WHEN DATEDIFF( DAY, t.created, piv2.IncidentTicketClosed ) > 49 THEN 7
	END AS OpenIncidentsGroupHandleKey,
	CASE
		WHEN DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) BETWEEN 0 AND 3 THEN 1
		WHEN DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) BETWEEN 4 AND 7 THEN 2
		WHEN DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) BETWEEN 8 AND 14 THEN 3
		WHEN DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) BETWEEN 15 AND 28 THEN 4
		WHEN DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) BETWEEN 29 AND 35 THEN 5
		WHEN DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) BETWEEN 36 AND 49 THEN 6
		WHEN DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) > 49 THEN 7
	END AS OpenIncidentsGroupInstallationToErrorKey,
	t.ID AS ChipperIncidentKey
	--ATTRUBUTES																										 
	,
	t.ID AS IncidentCode,
	t.[item.lid] AS IncidentLidCode,
	t.[product.id] AS IncidentProduct,
	SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ) AS TechnologyInstalled
	--MEASURES																											 
	,
	1 AS IncidentCreated,
	IIF( t.Status = 'CLOSED', 1, 0 ) AS IncidentClosed,
	IIF( ISNULL( piv.IncidentTicketPicked, 0 ) <> 0, 1, 0 ) AS IncidentPicked,
	IIF( ISNULL( piv.IncidentTicketDerived, 0 ) <> 0, 1, 0 ) AS IncidentDerived,
	IIF( ISNULL( piv.IncidentTicketCancelled, 0 ) <> 0, 1, 0 ) AS IncidentCancelled,
	CONVERT( DATE, piv2.IncidentTicketClosed ) AS CalendarClosedKey,
	CONVERT( DATE, piv2.IncidentTicketPicked ) AS CalendarPickedKey,
	CONVERT( DATE, piv2.IncidentTicketDerived ) AS CalendarDerivedKey,
	CONVERT( DATE, piv2.IncidentTicketCancelled ) AS CalendarCancelledKey,
	DATEDIFF( DAY, t.created, piv2.IncidentTicketPicked ) AS IncidentResponseTime,
	IIF( t.Status = 'OPEN', DATEDIFF( DAY, t.created, GETDATE() ), NULL ) AS IncidentDaysOpen --Udfordringer med at tickets bliver opdateret til lukket. Tjek flere der har været åbne i noget tid op mod adf kørsler og ADL filerne. d 2023-01-05 14:00 kørsel "fejlet" da payload var for stort
	,
	DATEDIFF( DAY, t.created, piv2.IncidentTicketClosed ) AS IncidentDaysToHandle,
	DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) AS DaysFromInstallationToError,
	PercentOfIncidents3DaysFromInstallation.PercentOfIncidents3DaysFromInstallation AS PercentOfIncidents3DaysFromInstallation,
	PercentOfIncidents14DaysFromInstallation.PercentOfIncidents14DaysFromInstallation AS PercentOfIncidents14DaysFromInstallation
FROM sourceNuuDataChipperView.[ChipperTicketsTickets_History] t
LEFT JOIN (
	SELECT
		ID,
		COALESCE( [eventLog.source.userId], [eventLog.source.error.userId] ) EventUserId,
		ROW_NUMBER() OVER (PARTITION BY ID ORDER BY [eventLog.timestamp] DESC) RN
	FROM sourceNuuDataChipperView.[ChipperTicketsEventLog_History]
	WHERE
		1 = 1
		AND DWIsCurrent = 1
		AND [eventLog.eventType] = 'IncidentTicketPicked'
) eventlog
	ON --Kan være picked flere gange, hvis den lægges tilbage igen. Tager seneste picked
		eventlog.ID = t.ID
		AND eventlog.RN = 1
LEFT JOIN ( --TODO: Dubletter på mails og medarbejder ID'er, da man godt kan tildele en anden person en mail, der har eksisteret før. Sørg for dato styring. Eksempelvis 'jone@yousee.dk'
	SELECT
		Email,
		EmployeeID,
		ROW_NUMBER() OVER (PARTITION BY Email ORDER BY SRC_DW_Valid_From DESC) RN
	FROM [sourceCubusMasterData].[DimEmployee]
	WHERE
		1 = 1
		AND NULLIF( Email, '' ) IS NOT NULL --UNDERSØG OLSK@yousee.dk, da denne har to medarbejderID'er - Samme mail givet til to forskellige personer. Dog ikke på samme tid
) e
	ON e.Email = eventlog.EventUserId--Konvertere mails til MedarbejderKey over til dim.Employee
		AND e.RN = 1
--Getusers i Chipper er ikke opdateret, så vi skal i nogle tilfælde benytte error, hvor error output er den mail, som ikke eksisterer i Chipper Getusers

LEFT JOIN (
	SELECT DISTINCT
		ID,
		tags
	FROM sourceNuuDataChipperView.[ChipperTicketsTags_History]
	WHERE
		DWIsCurrent = 1
		AND tags IN ('yousee', 'erhverv')
) tags
	ON tags.ID = t.ID
LEFT JOIN (
	SELECT DISTINCT
		(SUBSTRING( LinkKundeID, 1, 10 ) + ' ' + REPLACE( SUBSTRING( LinkKundeID, 12, 19 ), '.', ':' )) AS CustomerKey,
		lid,
		Technology
	FROM [sourceCubus31PCTI].[BUI_915_Customers_CU]
) tech
	ON t.[item.lid] = tech.lid
LEFT JOIN (
	SELECT
		lid,
		Product,
		ROW_NUMBER() OVER (PARTITION BY lid ORDER BY START_DATO DESC) RN --Få tilfælde af forskellige infrastruktur på samme LID. Tager den tættest på, hvornår en Incident er oprettet
	FROM #AFT_LID a

INNER JOIN #InfratructureProducts b
	ON b.ABONNEMENT_ID = a.ABONNEMENT_ID

INNER JOIN sourceNuuDataChipperView.[ChipperTicketsTickets_History] c
	ON c.[item.lid] = a.lid
		AND CONVERT( DATE, a.START_DATO ) <= CONVERT( DATE, c.created )
		AND c.DWIsCurrent = 1
) ifp
	ON ifp.lid = t.[item.lid]
		AND ifp.RN = 1

LEFT JOIN SourceNuudlBIZView.[DimProduct_History] p
	ON p.ProductID = ifp.Product
		AND p.DWIsCurrent = 1

LEFT JOIN (

	SELECT
		ID,
		IncidentTicketClosed,
		IncidentTicketPicked,
		IncidentTicketDerived,
		IncidentTicketCancelled
	FROM (
		SELECT
			ID,
			[eventLog.eventType]
		FROM sourceNuuDataChipperView.[ChipperTicketsEventLog_History]
		WHERE
			DWIsCurrent = 1
	) ec
	PIVOT
	(
	COUNT( [eventLog.eventType] )
	FOR [eventLog.eventType] IN (IncidentTicketClosed, IncidentTicketPicked, IncidentTicketDerived, IncidentTicketCancelled)
	) piv

) piv
	ON piv.ID = t.ID

LEFT JOIN (

	SELECT
		ID,
		IncidentTicketClosed,
		IncidentTicketPicked,
		IncidentTicketDerived,
		IncidentTicketCancelled
	FROM (
		SELECT
			ID,
			[eventLog.eventType],
			[eventLog.timestamp]
		FROM sourceNuuDataChipperView.[ChipperTicketsEventLog_History]
		WHERE
			DWIsCurrent = 1
	) ec
	PIVOT
	(
	MAX( [eventLog.timestamp] )
	FOR [eventLog.eventType] IN (IncidentTicketClosed, IncidentTicketPicked, IncidentTicketDerived, IncidentTicketCancelled)
	) piv

) piv2
	ON piv2.ID = t.ID

LEFT JOIN (

	SELECT
		lid,
		SUBSTRING( CAST( START_DATO AS NVARCHAR ), 1, 10 ) AS START_DATO,
		IncidentCode,
		ROW_NUMBER() OVER (PARTITION BY lid, IncidentCode ORDER BY START_DATO DESC) RN -- Tager den SENESTE start dato, der matcher i tilfælde af periode overlap. 
	-- 2023-03-10 er der kun 3 LID'er med overlap. 
	FROM #LIDSTART
) lid
	ON lid.lid = t.[item.lid]
		AND lid.RN = 1
		AND lid.IncidentCode = t.ID

LEFT JOIN #PercentOfIncidents3DaysFromInstallation PercentOfIncidents3DaysFromInstallation
	ON PercentOfIncidents3DaysFromInstallation.START_DATO = SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 )
		AND DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) BETWEEN 0 AND 3
LEFT JOIN #PercentOfIncidents14DaysFromInstallation PercentOfIncidents14DaysFromInstallation
	ON PercentOfIncidents14DaysFromInstallation.START_DATO = SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 )
		AND DATEDIFF( DAY, SUBSTRING( CAST( lid.START_DATO AS NVARCHAR ), 1, 10 ), t.created ) BETWEEN 0 AND 14

WHERE
	t.DWIsCurrent = 1


INSERT INTO stage.Fact_ChipperIncidents ( CalendarKey, Legacy_EmployeeKey, FAM_SalesChannelKey, FAM_ChipperStatusKey, Legacy_CustomerKey, FAM_InfrastructureKey, FAM_TechnologyKey, Legacy_ProductKey, FAM_OpenIncidentsGroupKey, FAM_OpenIncidentsGroupHandleKey, FAM_OpenIncidentsGroupInstallationToErrorKey, FAM_ChipperIncidentKey, IncidentCode, IncidentLidCode, IncidentProduct, TechnologyInstalled, IncidentCreated, IncidentClosed, IncidentPicked, IncidentDerived, IncidentCancelled, CalendarClosedKey, CalendarPickedKey, CalendarDerivedKey, CalendarCancelledKey, IncidentResponseTime, IncidentDaysOpen, IncidentDaysToHandle, DaysFromInstallationToError, PercentOfIncidents3DaysFromInstallation, PercentOfIncidents14DaysFromInstallation, IncidentRepeating3Days, IncidentRepeating14Days, DWCreatedDate )
SELECT
	CalendarKey,
	EmployeeKey,
	SalesChannelKey,
	ChipperStatusKey,
	CustomerKey,
	InfrastructureKey,
	TechnologyKey,
	ProductKey,
	OpenIncidentsGroupKey,
	OpenIncidentsGroupHandleKey,
	OpenIncidentsGroupInstallationToErrorKey,
	ChipperIncidentKey,
	IncidentCode,
	IncidentLidCode,
	IncidentProduct,
	TechnologyInstalled,
	IncidentCreated,
	IncidentClosed,
	IncidentPicked,
	IncidentDerived,
	IncidentCancelled,
	CalendarClosedKey,
	CalendarPickedKey,
	CalendarDerivedKey,
	CalendarCancelledKey,
	IncidentResponseTime,
	IncidentDaysOpen,
	IncidentDaysToHandle,
	DaysFromInstallationToError,
	PercentOfIncidents3DaysFromInstallation,
	PercentOfIncidents14DaysFromInstallation,
	CASE
		WHEN EXISTS
		(
			SELECT
				IncidentLidCode,
				IncidentCode
			FROM #Incidents ii
			WHERE
				ii.IncidentCode <> i.IncidentCode
				AND ii.IncidentLidCode = i.IncidentLidCode
				AND DATEDIFF( DAY, ii.CalendarKey, i.CalendarKey ) BETWEEN 0 AND 3
		) THEN 1
		ELSE 0
	END AS IncidentRepeating3Days,
	CASE
		WHEN EXISTS
		(
			SELECT
				IncidentLidCode,
				IncidentCode
			FROM #Incidents iii
			WHERE
				iii.IncidentCode <> i.IncidentCode
				AND iii.IncidentLidCode = i.IncidentLidCode
				AND DATEDIFF( DAY, iii.CalendarKey, i.CalendarKey ) BETWEEN 0 AND 14
		) THEN 1
		ELSE 0
	END AS IncidentRepeating14Days,
	GETDATE() AS DWCreatedDate
FROM #Incidents i