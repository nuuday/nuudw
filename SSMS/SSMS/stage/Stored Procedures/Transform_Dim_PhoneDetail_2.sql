
CREATE PROCEDURE [stage].[Transform_Dim_PhoneDetail]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_PhoneDetail]

INSERT INTO stage.[Dim_PhoneDetail] WITH (TABLOCK) (PhoneDetailkey, PhoneStatus,PhoneCategory,PortedIn,PortedOut,DWCreatedDate)

SELECT
       
	   
	   CONVERT( NVARCHAR(20), ISNULL( NULLIF( phone_number, '' ), '?' ) ) AS PhoneDetailkey,
	   CONVERT( NVARCHAR(20), ISNULL( NULLIF( status, '' ), '?' ) ) AS PhoneStatus,
	   CONVERT( NVARCHAR(20), ISNULL( NULLIF( category, '' ), '?' ) ) AS PhoneCategory,
	   ported_in AS PortedIn,
	   ported_out AS PortedOut,
	   GETDATE() AS DWCreatedDate
FROM [sourceNuudlNetCrackerView].[riphonenumber_History]