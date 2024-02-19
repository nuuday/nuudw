
CREATE PROCEDURE [stage].[Transform_Fact_ProductTransactions]
	@JobIsIncremental BIT			
AS 
TRUNCATE TABLE [stage].[Fact_ProductTransactions]

-- Historical and current active,disconnected,completed TLO Product transactions.
;with productinstance as
(

SELECT DISTINCT 
id,
active_from start_date,
item_json_offeringId offering_id,
item_json_customerId customer_id,
state,
item_json_quoteId quote_id,
active_to termination_date,
item_json_parentId parent_id,
item_json_rootId root_id,
item_json_offeringName offeringname,
item_json_distributionChannelId distributionChannelId,
item_json_accountRef_json_refId account_ref_id 

FROM  [sourceNuudlNetCrackerView].[ibsitemshistory_History]

WHERE (state in ('ACTIVE','DISCONNECTED') and (item_json_parentId IS NULL OR item_json_rootId  = id) 
or (state='COMPLETED' and item_json_accountRef_json_refId is not null and (item_json_parentId IS NULL OR item_json_rootId  = id)))
and id not in ('b5beb355-0379-41f2-aaad-47297c9548cb','39476242-7ab7-467e-b88a-b3968a8cb7e9') --we are excluding those subscriptions because of data issues due to testing activities in production

union all

-- Historical and current active,disconnected,completed SLO Product transactions.
SELECT DISTINCT 
a.id,
active_from start_date,
item_json_offeringId offering_id,
item_json_customerId customer_id,
state,
item_json_quoteId quote_id,
active_to termination_date,
item_json_parentId parent_id,
item_json_rootId root_id,
item_json_offeringName offeringname,
item_json_distributionChannelId distributionChannelId,
b.item_json_accountRef_json_refId account_ref_id 
FROM  [sourceNuudlNetCrackerView].[ibsitemshistory_History] a
Left join ( SELECT DISTINCT item_json_rootId id,item_json_accountRef_json_refId FROM  [sourceNuudlNetCrackerView].[ibsitemshistory_History] 
			where state in ('ACTIVE','DISCONNECTED','COMPLETED') and (item_json_parentId IS NULL OR item_json_rootId  = id) and id not in ('b5beb355-0379-41f2-aaad-47297c9548cb','39476242-7ab7-467e-b88a-b3968a8cb7e9')) b on a.item_json_rootId=b.id

WHERE a.state in ('ACTIVE','DISCONNECTED','COMPLETED') and a.item_json_parentId IS NOT NULL 
),
-- reference to BillingAccount
BillingAccount AS
(
SELECT id,account_num FROM
(
SELECT DISTINCT id,item_json_accountRef_json_refId account_ref_id FROM [sourceNuudlNetCrackerView].[ibsitemshistory_History]

WHERE item_json_parentId  IS NULL

UNION

SELECT DISTINCT a.id,b.account_ref_id FROM [sourceNuudlNetCrackerView].[ibsitemshistory_History] a


LEFT JOIN 
(
SELECT DISTINCT id,item_json_accountRef_json_refId account_ref_id FROM [sourceNuudlNetCrackerView].[ibsitemshistory_History]
WHERE item_json_parentId  IS NULL
) b ON a.item_json_rootId=b.id
WHERE a.item_json_parentId IS NOT NULL

) ww
INNER JOIN   [sourceNuudlNetCrackerView].[nrmaccountkeyname_History] xx on ww.account_ref_id=xx.name
),

-- Migration =1 if it's product change within the same category , Migration=0 if it's product change withing different category.
productinstance_t AS (
SELECT
id,
start_date,
offering_id,
customer_id,
state,
quote_id,
termination_date,
parent_id,
root_id,
offeringname,
Migration,
distributionChannelId,
account_ref_id
FROM (
SELECT a.*,b.name,

CASE WHEN LAG(b.name) OVER (PARTITION BY a.id ORDER BY ISNULL(termination_date,'9999-12-31') )=b.name   AND parent_id IS NULL AND LAG(A.OFFERING_ID) OVER (PARTITION BY a.id ORDER BY ISNULL(termination_date,'9999-12-31') ) <> a.offering_id THEN 1 
     WHEN LAG(b.name) OVER (PARTITION BY a.id ORDER BY ISNULL(termination_date,'9999-12-31') )<>b.name  AND parent_id IS NULL AND LAG(A.OFFERING_ID) OVER (PARTITION BY a.id ORDER BY ISNULL(termination_date,'9999-12-31') ) <> a.offering_id THEN 0 ELSE NULL END Migration
FROM productinstance a
-- 'Mobile Voice Offline' and 'Mobile Voice should be treated like same category and 'Mobile Broadband Offline','Mobile Broadband'
LEFT JOIN ( SELECT c.id,CASE WHEN d.name ='Mobile Voice Offline' THEN 'Mobile Voice' WHEN d.name ='Mobile Broadband Offline' THEN 'Mobile Broadband' ELSE d.name  END AS name  
FROM [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] c
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductfamily_History] d ON c.product_family_id=d.id) b ON a.offering_id=b.id
) c
)

INSERT INTO stage.[Fact_ProductTransactions] WITH (TABLOCK) ( ProductTransactionsIdentifier,BillingAccountKey,SubscriptionKey, CalendarKey,TimeKey, ProductKey, CustomerKey,AddressBillingKey,HouseHoldkey,SalesChannelKey,TransactionStateKey,QuoteKey,ProductTransactionsQuantity,ProductChurnQuantity,CalendarToKey,TimeToKey,CalendarCommitmentToKey,TimeCommitmentToKey,PhoneDetailkey,TLO,ProductParentKey,SubscriptionParentKey,RGU,CalendarRGUkey,CalendarRGUTokey,Migration,ProductUpgrade, DWCreatedDate )

SELECT
DISTINCT
	CONVERT(
    VARCHAR(64),
    HASHBYTES(
        'SHA2_256'
        , CONCAT(            
            /* Add all dimension keys to secure the row will be unique */
              LOWER(ISNULL(CAST(CalendarKey AS VARCHAR(8000)), '')), '|'
            , LOWER(ISNULL(CAST(TimeKey AS VARCHAR(8000)), '')), '|'
            , LOWER(ISNULL(CAST(ProductKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(ProductKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(CustomerKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(AddressBillingKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(HouseHoldkey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(TransactionStateKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(CalendarToKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(TimeToKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(CalendarCommitmentToKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(TimeCommitmentToKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(PhoneDetailkey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(ProductParentKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(Subscriptionkey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(SubscriptionParentKey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(BillingAccountkey AS VARCHAR(8000)), '')), '|'
			, LOWER(ISNULL(CAST(Quotekey AS VARCHAR(8000)), '')), '|'
            )
        ),
    2
    ) AS ProductTransactionsIdentifier
	,z.*
	From
	(
	SELECT
	CONVERT( NVARCHAR(12), acc.account_num ) AS BillingAccountKey,  
	CONVERT( NVARCHAR(36), pin.id ) AS SubscriptionKey,  
	CONVERT( DATE, REPLACE( pin.start_date, '"', '' ) ) AS CalendarKey,
	LEFT(CONVERT(VARCHAR,start_date,108),5)+':00' AS TimeKey,
	CONVERT( NVARCHAR(36), REPLACE( pin.offering_id, '"', '' ) ) AS ProductKey, 
	CONVERT( NVARCHAR(12), REPLACE( cim.customer_number, '"', '' ) ) AS CustomerKey,
	CONVERT( NVARCHAR(50), REPLACE( ab.AddressBillingKey, '"', '' ) ) AS AddressBillingKey, 
	CONVERT( NVARCHAR(36), REPLACE( HouseHold.id, '"', '' ) ) AS HouseHoldkey ,
	CONVERT( NVARCHAR(36), REPLACE( pin.distributionChannelId, '"', '' ) ) AS SalesChannelKey,
	CASE WHEN pin.state='ACTIVE' THEN 1 WHEN pin.state='DISCONNECTED' THEN 2 WHEN pin.state='COMPLETED' THEN 3 END AS TransactionStateKey,
	CONVERT( NVARCHAR(10), REPLACE( quote.number, '"', '' ) ) AS QuoteKey, 
	
	CASE WHEN  Migration=0 OR( Migration IS NULL AND pin.state='ACTIVE' AND (LEAD(Migration) OVER (PARTITION BY pin.id ORDER BY ISNULL(pin.termination_date,'9999-12-31')))=1 AND ROW_NUMBER() OVER (PARTITION BY pin.id ,pin.offering_id ORDER BY pin.start_date )=1  ) OR (Migration IS NULL AND pin.state='ACTIVE' AND pin.termination_date IS NULL AND ROW_NUMBER() OVER (PARTITION BY pin.id ,pin.offering_id ORDER BY pin.start_date )=1 ) THEN 1 
		 WHEN pin.state='DISCONNECTED' THEN -1 
		 WHEN pin.state='COMPLETED' OR Migration=1 OR  ROW_NUMBER() OVER (PARTITION BY pin.id ,pin.offering_id ORDER BY pin.start_date )<>1  THEN 0 ELSE 1 END AS ProductTransactionsQuantity,
	
	CASE WHEN LEAD(Migration) OVER (PARTITION BY pin.id ORDER BY ISNULL(pin.termination_date,'9999-12-31'))=0 THEN -1 ELSE 0 END AS ProductChurnQuantity,
	CASE WHEN pin.state='DISCONNECTED' THEN CONVERT( DATE, REPLACE( pin.start_date, '"', '' ) ) ELSE  CONVERT( DATE, pin.termination_date ) END AS CalendarToKey,
	CASE WHEN pin.state='DISCONNECTED' THEN LEFT(CONVERT(VARCHAR,start_date,108),5)+':00' ELSE LEFT(CONVERT(VARCHAR,pin.termination_date ,108),5)+':00' END AS TimeToKey,
	CONVERT( DATE, com.expiration_date ) AS CalendarCommitmentToKey,
	LEFT(CONVERT(VARCHAR,CONVERT( DATETIME, com.expiration_date  ) ,108),5)+':00' AS TimeCommitmentToKey,
	CONVERT( NVARCHAR(20), REPLACE(REPLACE(chr.value_json__corrupt_record,'["',''),'"]','') ) AS PhoneDetailkey,
	CONVERT( NVARCHAR(1), CASE WHEN pin.parent_id IS NULL OR pin.root_id = pin.id THEN 1 ELSE 0 END ) AS TLO,
	CONVERT( NVARCHAR(36), REPLACE( parent.offering_id, '"', '' ) ) AS ProductParentKey,
	CONVERT( NVARCHAR(36), REPLACE( parent.parent_id, '"', '' ) ) AS SubscriptionParentKey, 
	CONVERT( NVARCHAR(1),CASE WHEN cu.ref IS NOT NULL AND (pin.parent_id IS NULL OR pin.root_id = pin.id) THEN 1 ELSE 0 END) AS RGU,
	CONVERT( DATE, CASE WHEN pin.parent_id IS NULL OR pin.root_id = pin.id THEN start_dat ELSE NULL END ) AS  CalendarRGUkey,
	CONVERT( DATE, CASE WHEN pin.parent_id IS NULL OR pin.root_id = pin.id THEN end_dat ELSE NULL END ) AS CalendarRGUTokey,
	CASE WHEN ( LEAD( Migration) OVER (ORDER BY pin.id,pin.start_date))=1 THEN -1 ELSE Migration END AS Migration,
	CASE WHEN Migration=1 AND prof.weight - LAG(prof.weight) OVER (PARTITION BY pin.id ORDER BY ISNULL(termination_date,'9999-12-31') ) > 0 THEN 1
	     WHEN Migration=1 AND prof.weight - LAG(prof.weight) OVER (PARTITION BY pin.id ORDER BY ISNULL(termination_date,'9999-12-31') ) < 0 THEN 0 ELSE NULL END AS ProductUpgrade,
	GETDATE() AS DWCreatedDate

FROM productinstance_t pin

-- reference to Quotekey,
LEFT JOIN [sourceNuudlNetCrackerView].[qssnrmlquote_History] quote ON quote.id=pin.quote_id

-- reference to PhoneDetailkey, SLO will have TLO phone number
LEFT JOIN [sourceNuudlNetCrackerView].[ibsnrmlcharacteristic_History] chr  ON chr.product_instance_id=ISNULL(pin.parent_id,pin.id) AND chr.name='International Phone Number' 

-- It's a RGU if a suscription have a financial start date
LEFT JOIN [sourceNuudlNetCrackerView].[nrmcusthasproductkeyname_History] kn ON kn.name=pin.id
LEFT JOIN 
			(   SELECT 
				CONCAT(product_seq,customer_ref) ref,product_label,override_product_name,start_dat,end_dat
				FROM [sourceNuudlNetCrackerView].[nrmcustproductdetails_History] ) cu ON cu.ref=CONCAT(kn.product_seq,kn.customer_ref) AND (pin.offeringname=cu.product_label OR pin.offeringname=cu.override_product_name ) AND  (CONVERT( DATE,pin.start_date )=DATEADD(day,1,CONVERT( DATE, cu.start_dat )))

-- reference to CalendarCommitmentToKey both for TLO & SLO
LEFT JOIN (SELECT DISTINCT id,item_json_expirationDate expiration_date,active_from FROM [sourceNuudlNetCrackerView].[ibsitemshistory_History]
WHERE  item_json_offeringName ='Commitment' AND item_json_expirationDate IS NOT NULL and state in ('ACTIVE','DISCONNECTED')
UNION ALL
SELECT DISTINCT item_json_parentId id,item_json_expirationDate expiration_date,active_from FROM [sourceNuudlNetCrackerView].[ibsitemshistory_History]
WHERE  item_json_offeringName ='Commitment' AND item_json_expirationDate IS NOT NULL and state='ACTIVE'
) com ON com.id=pin.id and CONVERT( SMALLDATETIME, com.active_from)<= CONVERT( SMALLDATETIME, pin.start_date)

-- reference to ProductParentKey for SLO
LEFT JOIN (SELECT a.id,b.offering_id,a.parent_id FROM [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] a
LEFT JOIN [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] b ON a.parent_id=b.id
WHERE a.parent_id IS NOT NULL 
) parent ON pin.id=parent.id

-- reference to HouseHoldkey
LEFT JOIN (	   SELECT DISTINCT
	   cm.id,
	   cma.ref_id
       FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
       INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
              ON cm.ID = cma.contact_medium_id
                      AND cm.is_current = 1
                      AND type_of_contact_method = 'Billing contact details') HouseHold ON pin.customer_id=HouseHold.ref_id

-- reference to AddressBillingKey
LEFT JOIN (
       SELECT
       cma.ref_id AS customer_id,
       CONCAT(ISNULL(cm.Street1,''),';',ISNULL(cm.Street2,''),';',ISNULL(cm.Postcode,''),';',ISNULL(cm.City,'')) AddressBillingKey
       FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
       INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
              ON cm.ID = cma.contact_medium_id
                      AND cm.is_current = 1
                      AND type_of_contact_method = 'Billing contact details'
       WHERE
              cma.is_current = 1
) ab ON ab.customer_id = pin.customer_id

-- ProductUpgrade
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] prof ON pin.offering_id=prof.id

-- BillingAccount
--LEFT JOIN BillingAccount acc ON pin.id=acc.id
LEFT JOIN [sourceNuudlNetCrackerView].[nrmaccountkeyname_History] acc on pin.account_ref_id=acc.name

-- reference to CustomerKey
LEFT JOIN [sourceNuudlNetCrackerView].[cimcustomer_History] cim ON pin.customer_id=cim.id
WHERE pin.offeringname NOT IN ('Assign Phone Number [MV or Smart SIM] #1','Assign Phone Number [MV or Smart SIM]') AND cim.is_current=1 -- offering 'Assign Phone Number [MV or Smart SIM] #1' is treated separately to be able to identify the old phone number.
--and pin.id='39476242-7ab7-467e-b88a-b3968a8cb7e9'
UNION ALL

SELECT 
	CONVERT( NVARCHAR(12), acc.account_num ) AS BillingAccountkey,
	CONVERT( NVARCHAR(36), pin.id ) AS Subscriptionkey,  
	CONVERT( DATE, REPLACE( pin.start_date, '"', '' ) ) AS CalendarKey,
	LEFT(CONVERT(VARCHAR,start_date,108),5)+':00' AS TimeKey,
	CONVERT( NVARCHAR(36), REPLACE( pin.offering_id, '"', '' ) ) AS ProductKey, 
	CONVERT( NVARCHAR(12), REPLACE( cim.customer_number, '"', '' ) ) AS CustomerKey,
	CONVERT( NVARCHAR(50), REPLACE( ab.AddressBillingKey, '"', '' ) ) AS AddressBillingKey,
	CONVERT( NVARCHAR(36), REPLACE( HouseHold.id, '"', '' ) ) AS HouseHoldkey,
	CONVERT( NVARCHAR(36), REPLACE( pin.distributionChannelId, '"', '' ) ) AS SalesChannelKey,
	CASE WHEN pin.state='ACTIVE' THEN 1 WHEN pin.state='DISCONNECTED' THEN 2 WHEN pin.state='COMPLETED' THEN 3 END AS TransactionStateKey,
	CONVERT( NVARCHAR(10), REPLACE( quote.number, '"', '' ) ) AS Quotekey,
    0 AS ProductTransactionsQuantity,
	0 AS ProductChurnQuantity,
	CONVERT( Date, pin.termination_date ) AS CalendarToKey,
	LEFT(CONVERT(VARCHAR,pin.termination_date ,108),5)+':00' AS TimeToKey,
    NULL AS CalendarCommitmentToKey,
	NULL AS TimeCommitmentToKey,
	CONVERT( NVARCHAR(20), REPLACE(REPLACE(chr.value_json__corrupt_record,'["',''),'"]','') ) AS PhoneDetailkey,
	CONVERT( NVARCHAR(1), CASE WHEN pin.parent_id is null or pin.root_id = pin.id THEN 1 ELSE 0 END ) AS TLO,
	CONVERT( NVARCHAR(36), REPLACE( parent.offering_id, '"', '' ) ) AS ProductParentKey,
	CONVERT( NVARCHAR(36), REPLACE( parent.parent_id, '"', '' ) ) AS SubscriptionParentKey,
	0 AS RGU,
	NULL AS Migration,
	NULL CalendarRGUkey,
	NULL CalendarRGUTokey,
	NULL AS ProductUpgrade,
	
	GETDATE() AS DWCreatedDate

FROM productinstance_t pin

LEFT JOIN [sourceNuudlNetCrackerView].[qssnrmlquote_History] quote ON quote.id=pin.quote_id
LEFT JOIN [sourceNuudlNetCrackerView].[ibsnrmlcharacteristic_History] chr  ON chr.product_instance_id=pin.id and chr.name='International Phone Number'

LEFT JOIN (SELECT a.id,b.offering_id,a.parent_id FROM [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] a
LEFT JOIN [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] b ON a.parent_id=b.id
WHERE a.parent_id IS NOT NULL 
) parent ON pin.id=parent.id

LEFT JOIN (	   SELECT DISTINCT
	   cm.id,
	   cma.ref_id
       FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
       INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
              ON cm.ID = cma.contact_medium_id
                      AND cm.is_current = 1
                      AND type_of_contact_method = 'Billing contact details') HouseHold ON pin.customer_id=HouseHold.ref_id
LEFT JOIN (
       SELECT
       cma.ref_id AS customer_id,
       CONCAT(ISNULL(cm.Street1,''),';',ISNULL(cm.Street2,''),';',ISNULL(cm.Postcode,''),';',ISNULL(cm.City,'')) AddressBillingKey
       FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
       INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
              ON cm.ID = cma.contact_medium_id
                      AND cm.is_current = 1
                      AND type_of_contact_method = 'Billing contact details'
       WHERE
              cma.is_current = 1
) ab ON ab.customer_id = pin.customer_id

--LEFT JOIN BillingAccount acc ON pin.id=acc.id
LEFT JOIN [sourceNuudlNetCrackerView].[nrmaccountkeyname_History] acc on pin.account_ref_id=acc.name

LEFT JOIN [sourceNuudlNetCrackerView].[cimcustomer_History] cim ON pin.customer_id=cim.id
where pin.offeringname  IN ('Assign Phone Number [MV or Smart SIM] #1','Assign Phone Number [MV or Smart SIM]') AND pin.state IN('COMPLETED')
AND cim.is_current=1 --and pin.id='39476242-7ab7-467e-b88a-b3968a8cb7e9'

) z