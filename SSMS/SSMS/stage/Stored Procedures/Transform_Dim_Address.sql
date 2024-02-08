
CREATE PROCEDURE [stage].[Transform_Dim_Address]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Address]


INSERT INTO stage.[Dim_Address] WITH (TABLOCK) (AddressKey, Street1, Street2,Postcode,City,DWCreatedDate)

	   SELECT DISTINCT
       CONCAT(ISNULL(cm.Street1,''),';',ISNULL(cm.Street2,''),';',ISNULL(cm.Postcode,''),';',ISNULL(cm.City,'')) AddressKey,
	   CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Street1, '' ), '?' ) ) AS Street1,
       CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Street2, '' ), '?' ) ) AS Street2,
       CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Postcode, '' ), '?' ) ) AS Postcode,
       CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.City, '' ), '?' ) ) AS City,
	   GETDATE() AS DWCreatedDate

       FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
       INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
              ON cm.ID = cma.contact_medium_id
                      AND cm.is_current = 1
                      AND type_of_contact_method = 'Billing contact details'
	   INNER JOIN (select distinct item_json_customerId customer_id from [sourceNuudlNetCrackerView].[ibsitemshistory_History] ) pin on pin.customer_id=cma.ref_id
       WHERE
              cma.is_current = 1 and CONCAT(ISNULL(cm.Street1,''),';',ISNULL(cm.Street2,''),';',ISNULL(cm.Postcode,''),';',ISNULL(cm.City,'')) <>';;;'