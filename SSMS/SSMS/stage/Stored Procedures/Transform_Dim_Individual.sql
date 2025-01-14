

CREATE PROCEDURE [stage].[Transform_Dim_Individual]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Individual]

INSERT INTO stage.[Dim_Individual] WITH (TABLOCK) ( [IndividualKey], [IndividualFamilyName], [IndividualGivenName], [IndividualLegalName], [IndividualCountry],
[IndividualCity], [IndividualPostcode], [IndividualStreet1], [IndividualStreet2], [IndividualEmail], [IndividualPhonenumber]  )

Select distinct
ind.id IndividualKey, im.family_name , im.given_name, im.legal_name,a.country,a.city,a.postcode,
a.street1,a.street2,a.email_address,a.phone_number
from sourceNuudlDawnView.cimindividual_History ind  
LEFT JOIN sourceNuudlDawnView.cimindividualname_History im ON im.individual_id = ind.id and im.NUUDL_IsLatest =1
Left Join 
(select ROW_NUMBER() OVER (PARTITION BY ref_id ORDER BY active_from desc, nuudl_id desc) rn,
-- count(1) over(PARTITION BY ref_id ORDER BY active_from desc) total, 
ref_id, 
    LEAD(cm.country,0,0) IGNORE NULLS over (partition by ref_id order by active_from desc, nuudl_id desc) as country,
    LEAD(cm.city,0,0) IGNORE NULLS over (partition by ref_id order by active_from desc, nuudl_id desc) as city,
    LEAD(cm.postcode,0,0) IGNORE NULLS over (partition by ref_id order by active_from desc, nuudl_id desc) as postcode,
    LEAD(cm.street1,0,0) IGNORE NULLS over (partition by ref_id order by active_from desc, nuudl_id desc) as street1,
    LEAD(cm.street2,0,0) IGNORE NULLS over (partition by ref_id order by active_from desc, nuudl_id desc) as street2,
    LEAD(cm.email_address,0,0) IGNORE NULLS over (partition by ref_id order by active_from desc, nuudl_id desc)as email_address,
    LEAD(COALESCE(cm.phone_number, cm.phone_ext_number),0,0) IGNORE NULLS over (partition by ref_id order by active_from desc, nuudl_id desc) as phone_number
from sourceNuudlDawnView.cimcontactmedium_History cm where nuudl_islatest=1 
 ) a 
on a.ref_id= ind.id  and rn=1
    where  ind.NUUDL_IsLatest =1