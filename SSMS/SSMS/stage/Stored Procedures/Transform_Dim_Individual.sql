

CREATE PROCEDURE [stage].[Transform_Dim_Individual]
	@JobIsIncremental BIT			
AS 

WITH cte_grp AS
(
    SELECT
        nuudl_id,ref_id, a.country,a.city,a.postcode,a.street1,a.street2,a.email_address,a.phone_number
        --, MAX(IIF(a.phone_number IS NOT NULL, nuudl_id,NULL)) OVER (PARTITION BY ref_id ORDER BY  nuudl_id --ROWS UNBOUNDED PRECEDING		) as grp
		, max(IIF(a.phone_number is not null, nuudl_id,null)) over (partition by ref_id) as a
		, max(IIF(a.country is not null, nuudl_id,null)) over (partition by ref_id) as b
		, max(IIF(a.city is not null, nuudl_id,null)) over (partition by ref_id) as c
		, max(IIF(a.postcode is not null, nuudl_id,null)) over (partition by ref_id) as d
		,max(IIF(a.street1 is not null, nuudl_id,null)) over (partition by ref_id) as e
		,max(IIF(a.street2 is not null, nuudl_id,null)) over (partition by ref_id) as f
		,max(IIF(a.email_address is not null, nuudl_id,null)) over (partition by ref_id) as g
    FROM sourceNuudlDawnView.cimcontactmedium_History a 
	where nuudl_islatest=1 --and ref_id = '0000a7b1-d109-4875-b224-376532659839'  --order by 1
)
SELECT
     nuudl_id,ref_id
	,  ROW_NUMBER() OVER (PARTITION BY ref_id ORDER BY  nuudl_id desc) rn
    ,  MAX(phone_number) OVER (PARTITION BY ref_id, a ORDER BY nuudl_id) as phone_number--ROWS UNBOUNDED PRECEDING
	,  MAX(email_address) OVER (PARTITION BY ref_id, g ORDER BY nuudl_id) as email_address --ROWS UNBOUNDED PRECEDING
	,  MAX(country) OVER (PARTITION BY ref_id, b ORDER BY nuudl_id) as country
	,  MAX(city) OVER (PARTITION BY ref_id, c ORDER BY nuudl_id) as city
	,  MAX(postcode) OVER (PARTITION BY ref_id, d ORDER BY nuudl_id) as postcode
	,  MAX(street1) OVER (PARTITION BY ref_id, e ORDER BY nuudl_id) as street1
	,  MAX(street2) OVER (PARTITION BY ref_id, f ORDER BY nuudl_id) as street2
	into #temp_contact_detail 
FROM cte_grp

TRUNCATE TABLE [stage].[Dim_Individual]

INSERT INTO stage.[Dim_Individual] WITH (TABLOCK) ( [IndividualKey], [IndividualFamilyName], [IndividualGivenName], [IndividualLegalName], [IndividualCountry],
[IndividualCity], [IndividualPostcode], [IndividualStreet1], [IndividualStreet2], [IndividualEmail], [IndividualPhonenumber]  )

Select  distinct 
ind.id IndividualKey, im.family_name , im.given_name, im.legal_name,a.country,a.city,a.postcode,
a.street1,a.street2,a.email_address,a.phone_number
from sourceNuudlDawnView.cimindividual_History ind  
LEFT JOIN sourceNuudlDawnView.cimindividualname_History im ON im.individual_id = ind.id and im.NUUDL_IsLatest =1
Left Join 
#temp_contact_detail a 
on a.ref_id= ind.id  and a.rn=1
    where  ind.NUUDL_IsLatest =1 --and ind.id ='1f3739c2-7c48-4640-9067-99be4b826305'