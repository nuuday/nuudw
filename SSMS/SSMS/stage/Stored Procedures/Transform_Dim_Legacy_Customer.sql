
CREATE PROCEDURE [stage].[Transform_Dim_Legacy_Customer]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Legacy_Customer]

INSERT INTO stage.[Dim_Legacy_Customer] WITH (TABLOCK) ( [Legacy_CustomerKey], [CustomerCode], [CustomerFirstname], [CustomerLastName], [CustomerBusinessName1], [CustomerBusinessName2], [CustomerNameLong], [CustomerCategory], [CustomerCVRCode], [CustomerCVRAbroadCode], [CustomerBirthDate], [CustomerGender], [CustomerStatus], [Legacy_CustomerIsCurrent], [Legacy_CustomerValidFromDate], [Legacy_CustomerValidToDate], [DWCreatedDate] )
SELECT DISTINCT
	[LINK_KUNDE_ID]  AS Legacy_CustomerKey,
	[LINK_KUNDENR] AS CustomerCode,
	(CASE
		WHEN [FORNAVN] IS NULL OR [FORNAVN] = 'UKENDT FORNAVN CU' THEN '?'
		ELSE [FORNAVN]
	END) AS CustomerFirstname,
	(CASE
		WHEN [EFTERNAVN] IS NULL OR [EFTERNAVN] = 'UKENDT EFTERNAVN CU ' THEN '?'
		ELSE [EFTERNAVN]
	END) AS CustomerLastName,
	(CASE
		WHEN [BUSINESS_NAVN1] IS NULL THEN '?'
		ELSE [BUSINESS_NAVN1]
	END) AS CustomerBusinessName1,
	(CASE
		WHEN [BUSINESS_NAVN2] IS NULL THEN '?'
		ELSE [BUSINESS_NAVN2]
	END) AS CustomerBusinessName2,
	(CASE
		WHEN [EFTERNAVN] <> '' AND [EFTERNAVN] IS NOT NULL THEN CONCAT( TRIM( [FORNAVN] ), ' ', TRIM( [EFTERNAVN] ) )
		WHEN [FORNAVN] <> '' AND [FORNAVN] IS NOT NULL THEN TRIM( [FORNAVN] )
		WHEN [BUSINESS_NAVN2] <> '' AND [BUSINESS_NAVN2] IS NOT NULL THEN CONCAT( TRIM( [BUSINESS_NAVN1] ), ' ', TRIM( [BUSINESS_NAVN2] ) )
		ELSE TRIM( [BUSINESS_NAVN1] )
	END) AS CustomerNameLong,
	(CASE
		WHEN [KUNDE_KATEGORI] = 'PERSON' THEN 'Person'
		WHEN [KUNDE_KATEGORI] = 'VIRKSOMHED' THEN 'Business'
		ELSE 'Unknown'
	END) AS CustomerCategory,
	[CVR_NR] AS CustomerCVRCode,
	UDLANDS_CVR_NR AS CustomerCVRAbroadCode,
	(CASE
		WHEN [FOEDSELSDATO] <= '1900-01-01' THEN '19000101'
		WHEN FOEDSELSDATO IS NULL THEN '19000101'
		ELSE FOEDSELSDATO
	END) AS CustomerBirthDate,
	(CASE
		WHEN [KOEN] IS NULL THEN '?'
		ELSE [KOEN]
	END) AS CustomerGender,
	(CASE
		WHEN [KUNDE_STATUS] IS NULL THEN '?'
		ELSE [KUNDE_STATUS]
	END) AS CustomerStatus,
	[DWIsCurrent] AS Legacy_CustomerIsCurrent,
	DATEADD( MILLISECOND, -DATEPART( MILLISECOND, [DWValidFromDate] ), DATEADD( SECOND, -DATEPART( SECOND, [DWValidFromDate] ), [DWValidFromDate] ) ) AS Legacy_CustomerValidFromDate,
	DATEADD( MILLISECOND, -DATEPART( MILLISECOND, [DWValidToDate] ), DATEADD( SECOND, -DATEPART( SECOND, [DWValidToDate] ), [DWValidToDate] ) ) AS Legacy_CustomerValidToDate,
	GETDATE() AS [DWCreatedDate]

FROM SourceNuudlLinkitView.LINK_KUNDE_History

/**************************************************************************************************************************************************************
Her fjernes kunder med fødselsdato over 100 år og under 18 år - formodentligt grundet fejlregistrering, eller datoer sat i stedet for en 'NULL' værdi
***************************************************************************************************************************************************************/
WHERE
	FOEDSELSDATO BETWEEN DATEADD( YEAR, -100, GETDATE() )
	AND DATEADD( YEAR, -18, GETDATE() )
	OR FOEDSELSDATO IS NULL