
CREATE PROCEDURE [stage].[Transform_Fact_ProductTransactions]
	@JobIsIncremental BIT			
AS 
TRUNCATE TABLE [stage].[Fact_ProductTransactions]

-- Historical active TLO transactions involve product change and the current subscriptions are active.
;with productinstance as
(
SELECT
id,
start_date,
offering_id,
customer_id,
state,
termination_date,
parent_id,
root_id,
eligibility_param_id
FROM(
SELECT DISTINCT 
a.id,
a.active_from start_date,
a.item_json_offeringId offering_id,
a.item_json_customerId customer_id,
a.state,
a.active_to termination_date,
a.item_json_parentId parent_id,
a.item_json_rootId root_id,
b.eligibility_param_id eligibility_param_id,
ROW_NUMBER() OVER (PARTITION BY a.id,a.item_json_offeringId ORDER BY active_to  DESC) rn
from  [sourceNuudlNetCrackerView].[ibsitemshistory_History] a
left join [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] b on a.id=b.id and b.state in('ACTIVE') and a.item_json_offeringId <>b.offering_id
where a.state='ACTIVE' and a.active_to is not null and b.state is not null and (a.item_json_parentId is null or a.item_json_rootId=a.id)) a

where a.rn=1 

-- Historical active TLO transactions where current subscriptions are DISCONNECTED.
union all

SELECT
id,
start_date,
offering_id,
customer_id,
state,
termination_date,
parent_id,
root_id,
eligibility_param_id
FROM(
SELECT DISTINCT 
a.id,
a.active_from start_date,
a.item_json_offeringId offering_id,
a.item_json_customerId customer_id,
a.state,
a.active_to termination_date,
a.item_json_parentId parent_id,
a.item_json_rootId root_id,
b.eligibility_param_id eligibility_param_id,
ROW_NUMBER() OVER (PARTITION BY a.id,a.item_json_offeringId ORDER BY active_to  DESC) rn
from  [sourceNuudlNetCrackerView].[ibsitemshistory_History] a
left join [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] b on a.id=b.id and b.state in('DISCONNECTED')
where a.state='ACTIVE' and a.active_to is not null and b.state is not null and (a.item_json_parentId is null or a.item_json_rootId=a.id)) a

where a.rn=1 

-- Historical active SLO transactions where current subscriptions are DISCONNECTED.
union all

SELECT
id,
start_date,
offering_id,
customer_id,
state,
termination_date,
parent_id,
root_id,
eligibility_param_id
FROM(
SELECT DISTINCT 
a.id,
a.active_from start_date,
a.item_json_offeringId offering_id,
a.item_json_customerId customer_id,
a.state,
a.active_to termination_date,
a.item_json_parentId parent_id,
a.item_json_rootId root_id,
b.eligibility_param_id eligibility_param_id,
ROW_NUMBER() OVER (PARTITION BY a.id,a.item_json_offeringId ORDER BY active_to  DESC) rn
from  [sourceNuudlNetCrackerView].[ibsitemshistory_History] a
left join [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] b on a.id=b.id and b.state in('DISCONNECTED')
where a.state='ACTIVE' and a.active_to is not null and b.state is not null and (a.item_json_parentId is not null)) a

where a.rn=1

union all

--Current subscriptions with state 'DISCONNECTED','ACTIVE' and 'COMPLETED' except the offering 'Assign Phone Number [MV or Smart SIM] #1' that it will be handled in the transform code below to be able identify Old phone number
select id,start_date,offering_id,customer_id,state,termination_date,parent_id,root_id,eligibility_param_id 
FROM [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History]
where state in('DISCONNECTED','ACTIVE','COMPLETED') and name <>'Assign Phone Number [MV or Smart SIM] #1' 

),

-- Changing the start date for the current suscription -- Migration =1 if it's product change within the same category , Migration=0 if it's product change withing different category.
productinstance_t as (
Select
id,
case when rn=1 and LastValue is not null  then LastValue else start_date end as start_date,
offering_id,
customer_id,
state,
termination_date,
parent_id,
root_id,
Migration,
eligibility_param_id
from (
select a.*,b.name,
ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY isnull(termination_date,'9999-12-31' ) DESC) rn,
 lag(termination_date) OVER (
        PARTITION BY a.id ORDER BY isnull(termination_date,'9999-12-31')
        ) AS LastValue,
case when lag(b.name) over (partition by a.id order by isnull(termination_date,'9999-12-31') )=b.name   and parent_id is null and lag(a.offering_id) over (partition by a.id order by isnull(termination_date,'9999-12-31') ) <> a.offering_id then 1 
     when lag(b.name) over (partition by a.id order by isnull(termination_date,'9999-12-31') )<>b.name   and parent_id is null and lag(a.offering_id) over (partition by a.id order by isnull(termination_date,'9999-12-31') ) <> a.offering_id then 0 else NULL END Migration
from productinstance a
left join ( select c.id,case when d.name ='Mobile Voice Offline' then 'Mobile Voice'else d.name  end as name  -- 'Mobile Voice Offline' and 'Mobile Voice should be treated like same category.
from [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] c
left  join [sourceNuudlNetCrackerView].[pimnrmlproductfamily_History] d on c.product_family_id=d.id) b on a.offering_id=b.id
) c
)


INSERT INTO stage.[Fact_ProductTransactions] WITH (TABLOCK) ( ProductTransactionsIdentifier,ProductInstance, CalendarKey,TimeKey, ProductKey, CustomerKey,AddressBillingKey,HouseHoldkey,SalesChannelKey,TransactionStateKey,ProductTransactionsQuantity,ProductChurnQuantity,CalendarToKey,TimeToKey,CalendarCommitmentToKey,TimeCommitmentToKey,PhoneDetailkey,TLO,ProductParentKey,RGU,Migration,ProductUpgrade, DWCreatedDate )

SELECT

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
			, LOWER(ISNULL(CAST(ProductInstance AS VARCHAR(8000)), '')), '|'
            )
        ),
    2
    ) AS ProductTransactionsIdentifier
	,z.*
	From
	(
	SELECT
	CONVERT( NVARCHAR(36), pin.id ) AS ProductInstance,  
	CONVERT( DATE, REPLACE( pin.start_date, '"', '' ) ) AS CalendarKey,
	LEFT(CONVERT(VARCHAR,start_date,108),5)+':00' AS TimeKey,
	CONVERT( NVARCHAR(36), REPLACE( pin.offering_id, '"', '' ) ) AS ProductKey, 
	CONVERT( NVARCHAR(12), REPLACE( cim.customer_number, '"', '' ) ) AS CustomerKey,
	CONVERT( NVARCHAR(50), REPLACE( ab.AddressBillingKey, '"', '' ) ) AS AddressBillingKey, 
	CONVERT( NVARCHAR(36), REPLACE( HouseHold.id, '"', '' ) ) AS HouseHoldkey ,
	CONVERT( NVARCHAR(36), REPLACE( iep.distribution_channel_id, '"', '' ) ) AS SalesChannelKey,
	Case when pin.state='ACTIVE' then 1 when pin.state='DISCONNECTED' then 2 when pin.state='COMPLETED' then 3 END AS TransactionStateKey,
	CASE WHEN  Migration=0 or( Migration is null and pin.state='ACTIVE'and (lead(Migration) over (partition by pin.id order by isnull(pin.termination_date,'9999-12-31')))=1) 
	or (Migration is null and pin.state='ACTIVE' and pin.termination_date is null) THEN 1 
	WHEN pin.state='DISCONNECTED'  THEN -1 
	When pin.state='COMPLETED' or Migration=1 Then 0 ELSE 1 END AS ProductTransactionsQuantity,
	Case when lead(Migration) over (partition by pin.id order by isnull(pin.termination_date,'9999-12-31'))=0 THEN -1 ELSE 0 END AS ProductChurnQuantity,
	CONVERT( Date, pin.termination_date ) AS CalendarToKey,
	LEFT(CONVERT(VARCHAR,pin.termination_date ,108),5)+':00' AS TimeToKey,
	CONVERT( Date, com.expiration_date ) AS CalendarCommitmentToKey,
	LEFT(CONVERT(VARCHAR,com.expiration_date ,108),5)+':00' AS TimeCommitmentToKey,
	CONVERT( NVARCHAR(20), REPLACE(REPLACE(chr.value_json__corrupt_record,'["',''),'"]','') ) AS PhoneDetailkey,
	CONVERT( NVARCHAR(1), CASE WHEN pin.parent_id is null or pin.root_id = pin.id THEN 1 ELSE 0 END ) AS TLO,
	CONVERT( NVARCHAR(36), REPLACE( parent.offering_id, '"', '' ) ) AS ProductParentKey, 
	CONVERT( NVARCHAR(1),Case when cu.ref is not null and (pin.parent_id is null or pin.root_id = pin.id) THEN 1 ELSE 0 END) AS RGU,
	CONVERT( NVARCHAR(1), Migration) AS Migration,
	case when Migration=1 and prof.weight - lag(prof.weight) over (partition by pin.id order by isnull(termination_date,'9999-12-31') ) > 0 then 1
	     when Migration=1 and prof.weight - lag(prof.weight) over (partition by pin.id order by isnull(termination_date,'9999-12-31') ) < 0 then 0 else NULL END AS ProductUpgrade,
	GETDATE() AS DWCreatedDate

FROM productinstance_t pin

-- reference to PhoneDetailkey, SLO will have TLO phone number
LEFT JOIN [sourceNuudlNetCrackerView].[ibsnrmlcharacteristic_History] chr  ON chr.product_instance_id=isnull(pin.parent_id,pin.id) and chr.name='International Phone Number' 

-- It's a RGU if a suscription have a financial start date
LEFT JOIN [sourceNuudlNetCrackerView].[nrmcusthasproductkeyname_History] kn ON kn.name=pin.id
LEFT JOIN 
			(   SELECT --account_num,
				CONCAT(product_seq,customer_ref) ref,ROW_NUMBER() OVER (PARTITION BY CONCAT(product_seq,customer_ref) ORDER BY ISNULL( start_dat, '9999-12-31' ) DESC) rn
				FROM [sourceNuudlNetCrackerView].[nrmcustproductdetails_History] ) cu ON cu.ref=CONCAT(kn.product_seq,kn.customer_ref) and rn=1

-- reference to CalendarCommitmentToKey both for TLO & SLO
LEFT JOIN (select id,expiration_date  FROM [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History]
where name='Commitment #1'
union all
select parent_id id ,expiration_date  FROM [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History]
where name='Commitment #1'
) com on com.id=pin.id

-- reference to ProductParentKey for SLO
LEFT JOIN (select a.id,b.offering_id from [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] a
left join [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] b on a.parent_id=b.id
where a.parent_id is not null 
) parent on pin.id=parent.id

-- reference to SalesChannelKey
LEFT JOIN sourceNuudlNetCrackerView.ibseligibilityparameters_History iep on pin.eligibility_param_id=iep.id

-- reference to HouseHoldkey
LEFT JOIN (	   SELECT DISTINCT
	   cm.id,
	   cma.ref_id
       FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
       INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
              ON cm.ID = cma.contact_medium_id
                      AND cm.is_current = 1
                      AND type_of_contact_method = 'Billing contact details') HouseHold on pin.customer_id=HouseHold.ref_id

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
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] prof on pin.offering_id=prof.id

-- reference to CustomerKey
LEFT JOIN [sourceNuudlNetCrackerView].[cimcustomer_History] cim on pin.customer_id=cim.id
where cim.is_current=1


-- offering 'Assign Phone Number [MV or Smart SIM] #1' is treated separately to be able to identify the old phone number.

union all

SELECT 
	CONVERT( NVARCHAR(36), pin.id ) AS ProductTransactionsIdentifier,  
	CONVERT( DATE, REPLACE( pin.start_date, '"', '' ) ) AS CalendarKey,
	LEFT(CONVERT(VARCHAR,start_date,108),5)+':00' AS TimeKey,
	CONVERT( NVARCHAR(36), REPLACE( pin.offering_id, '"', '' ) ) AS ProductKey, 
	CONVERT( NVARCHAR(12), REPLACE( cim.customer_number, '"', '' ) ) AS CustomerKey,
	CONVERT( NVARCHAR(50), REPLACE( ab.AddressBillingKey, '"', '' ) ) AS AddressBillingKey,
	CONVERT( NVARCHAR(36), REPLACE( HouseHold.id, '"', '' ) ) AS HouseHoldkey,
	CONVERT( NVARCHAR(36), REPLACE( iep.distribution_channel_id, '"', '' ) ) AS SalesChannelKey,
	Case when pin.state='ACTIVE' then 1 when pin.state='DISCONNECTED' then 2 when pin.state='COMPLETED' then 3 END AS TransactionStateKey,
    0 AS ProductTransactionsQuantity,
	0 AS ProductChurnQuantity,
	CONVERT( Date, pin.termination_date ) AS CalendarToKey,
	LEFT(CONVERT(VARCHAR,pin.termination_date ,108),5)+':00' AS TimeToKey,
    NULL AS CalendarCommitmentToKey,
	NULL AS TimeCommitmentToKey,
	CONVERT( NVARCHAR(20), REPLACE(REPLACE(chr.value_json__corrupt_record,'["',''),'"]','') ) AS PhoneDetailkey,
	CONVERT( NVARCHAR(1), CASE WHEN pin.parent_id is null or pin.root_id = pin.id THEN 1 ELSE 0 END ) AS TLO,
	CONVERT( NVARCHAR(36), REPLACE( parent.offering_id, '"', '' ) ) AS ProductParentKey, 
	0 AS RGU,
	NULL AS Migration,
	NULL AS ProductUpgrade,
	
	GETDATE() AS DWCreatedDate

FROM [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] pin


LEFT JOIN [sourceNuudlNetCrackerView].[ibsnrmlcharacteristic_History] chr  ON chr.product_instance_id=pin.id and chr.name='International Phone Number'
LEFT JOIN (select a.id,b.offering_id from [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] a
left join [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History] b on a.parent_id=b.id
where a.parent_id is not null 
) parent on pin.id=parent.id

LEFT JOIN sourceNuudlNetCrackerView.ibseligibilityparameters_History iep on pin.eligibility_param_id=iep.id
LEFT JOIN (	   SELECT DISTINCT
	   cm.id,
	   cma.ref_id
       FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
       INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
              ON cm.ID = cma.contact_medium_id
                      AND cm.is_current = 1
                      AND type_of_contact_method = 'Billing contact details') HouseHold on pin.customer_id=HouseHold.ref_id
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

LEFT JOIN [sourceNuudlNetCrackerView].[cimcustomer_History] cim on pin.customer_id=cim.id
where pin.state in('COMPLETED') and pin.name ='Assign Phone Number [MV or Smart SIM] #1'
and cim.is_current=1

) z