
CREATE PROCEDURE [stage].[Transform_Dim_PhoneDetail]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_PhoneDetail]

;WITH PhoneDetail AS (
	SELECT 
		*
		, ROW_NUMBER() OVER (PARTITION BY q.PhoneDetailkey ORDER BY Ranking) rn
	FROM (

		SELECT
			CONVERT( NVARCHAR(20), ISNULL( NULLIF( cast(phone_number as varchar), '' ), '?' ) ) AS PhoneDetailkey,
			CONVERT( NVARCHAR(20), ISNULL( NULLIF( status, '' ), '?' ) ) AS PhoneStatus,
			CONVERT( NVARCHAR(20), ISNULL( NULLIF( category, '' ), '?' ) ) AS PhoneCategory,
			ported_in AS PortedIn,
			ported_out AS PortedOut,
			1 Ranking
		FROM [sourceNuudlDawnView].[phonenumbers_History]
		WHERE NUUDL_IsCurrent = 1

		UNION ALL

		SELECT DISTINCT
			CAST(international_phone_number as nvarchar(20)) PhoneDetailkey,
			'?' PhoneStatus,
			'?' PhoneCategory,
			0 PortedIn,
			0 PortedOut,
			2 Ranking
		FROM [sourceNuudlDawnView].[ibsitemshistorycharacteristics_History] chr
		WHERE international_phone_number IS NOT NULL
			AND NUUDL_IsCurrent = 1

		) q
)

INSERT INTO stage.[Dim_PhoneDetail] WITH (TABLOCK) (PhoneDetailkey, PhoneStatus,PhoneCategory,PortedIn,PortedOut)
SELECT PhoneDetailkey,PhoneStatus,PhoneCategory,PortedIn,PortedOut
FROM PhoneDetail
WHERE rn = 1