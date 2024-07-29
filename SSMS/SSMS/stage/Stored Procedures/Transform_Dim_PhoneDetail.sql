
CREATE PROCEDURE [stage].[Transform_Dim_PhoneDetail]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE stage.[Dim_PhoneDetail]

DROP TABLE IF EXISTS #phone_numbers
SELECT DISTINCT
	ROW_NUMBER() OVER (ORDER BY NUUDL_ValidFrom) ID,
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( cast(phone_number as varchar), '' ), '?' ) ) AS PhoneDetailkey,
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( status, '' ), '?' ) ) AS PhoneStatus,
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( category, '' ), '?' ) ) AS PhoneCategory,
	ported_in AS PortedIn,
	ported_out AS PortedOut,
	ISNULL(ported_in_from,'?') AS PortedInFrom,
	ISNULL(ported_out_to,'?') AS PortedOutTo,
	CAST(CAST(NUUDL_ValidFrom as date) as datetime2(0)) AS ValidFromDate,
	CAST(CAST(NUUDL_ValidTo as date) as datetime2(0)) AS ValidToDate,
	CAST(LEAD(NUUDL_ValidFrom,1) OVER (PARTITION BY phone_number ORDER BY NUUDL_ValidFrom) as date) LeadValidFrom
	,NUUDL_ValidFrom
INTO #phone_numbers
FROM [sourceNuudlDawnView].[phonenumbers_History]
--WHERE phone_number = '4520100000'


CREATE CLUSTERED INDEX CLIX ON #phone_numbers (PhoneDetailkey, ValidFromDate)

;WITH phone_numbers_daily AS (

	SELECT 
		*
		,LAG(ID,1) OVER (PARTITION BY PhoneDetailkey ORDER BY ValidFromDate) PreviousID
	FROM #phone_numbers
	WHERE ValidFromDate <> ISNULL(LeadValidFrom,'1900-01-01')

)
, phone_numbers_daily_collapsed AS (

	SELECT 
		c.*
	FROM phone_numbers_daily c
	LEFT JOIN phone_numbers_daily p ON p.ID = c.PreviousID
	CROSS APPLY (
		SELECT COUNT(*) Cnt
		FROM (
			SELECT c.PhoneStatus, c.PhoneCategory, c.PortedIn, c.PortedOut, c.PortedInFrom, c.PortedOutTo
			UNION 
			SELECT p.PhoneStatus, p.PhoneCategory, p.PortedIn, p.PortedOut, p.PortedInFrom, p.PortedOutTo
		) q
	) change
	WHERE Change.Cnt=2

)
INSERT INTO stage.[Dim_PhoneDetail] WITH (TABLOCK) (PhoneDetailValidFromDate, PhoneDetailValidToDate, PhoneDetailIsCurrent, PhoneDetailkey, PhoneStatus,PhoneCategory,PortedIn,PortedOut, PortedInFrom, PortedOutTo)
SELECT 
	ValidFromDate
	, ISNULL(LEAD(ValidFromDate,1) OVER (PARTITION BY PhoneDetailkey ORDER BY ValidFromDate),'9999-12-31') ValidToDate
	, CASE WHEN LEAD(ValidFromDate,1) OVER (PARTITION BY PhoneDetailkey ORDER BY ValidFromDate) IS NULL THEN 1 ELSE 0 END IsCurrent
	, PhoneDetailkey
	, PhoneStatus
	, PhoneCategory
	, PortedIn
	, PortedOut
	, PortedInFrom
	, PortedOutTo
FROM phone_numbers_daily_collapsed