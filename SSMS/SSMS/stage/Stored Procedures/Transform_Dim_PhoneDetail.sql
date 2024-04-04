
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
			CONVERT( NVARCHAR(20), ISNULL( NULLIF( phone_number, '' ), '?' ) ) AS PhoneDetailkey,
			CONVERT( NVARCHAR(20), ISNULL( NULLIF( status, '' ), '?' ) ) AS PhoneStatus,
			CONVERT( NVARCHAR(20), ISNULL( NULLIF( category, '' ), '?' ) ) AS PhoneCategory,
			ported_in AS PortedIn,
			ported_out AS PortedOut,
			GETDATE() AS DWCreatedDate,
			1 Ranking
		FROM [sourceNuudlNetCrackerView].[riphonenumber_History]

		UNION ALL

		SELECT DISTINCT
			CONVERT( NVARCHAR(20), TRIM(TRANSLATE( value_json__corrupt_record, '["]', '   ' )) ) PhoneDetailkey,
			'?' PhoneStatus,
			'?' PhoneCategory,
			0 PortedIn,
			0 PortedOut,
			GETDATE() AS DWCreatedDate,
			2 Ranking
		FROM [sourceNuudlNetCrackerView].[ibsnrmlcharacteristic_History] chr
		WHERE chr.name = 'International Phone Number'
		) q
)

INSERT INTO stage.[Dim_PhoneDetail] WITH (TABLOCK) (PhoneDetailkey, PhoneStatus,PhoneCategory,PortedIn,PortedOut,DWCreatedDate)
SELECT PhoneDetailkey,PhoneStatus,PhoneCategory,PortedIn,PortedOut,DWCreatedDate
FROM PhoneDetail
WHERE rn = 1