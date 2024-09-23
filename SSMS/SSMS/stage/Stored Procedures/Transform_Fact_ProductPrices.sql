--/****** Object:  StoredProcedure [stage].[Transform_Fact_ProductPrices]    Script Date: 31-07-2024 06:26:29 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE PROCEDURE [stage].[Transform_Fact_ProductPrices]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Fact_ProductPrices]

DROP TABLE IF EXISTS #product_dates

;WITH product_price_dates AS (
	SELECT  po.name AS product_name
			, po.id AS product_id
			, ISNULL(pck.available_from_CET,'9999-12-31')  available_from
			, ISNULL(IIF(DATEPART(ss,pck.available_to_CET) = 59, DATEADD(ss,1,pck.available_to_CET), pck.available_to_CET),'9999-12-31') available_to
			, ISNULL(pci.applied_from_CET,'9999-12-31') applied_from
			, ISNULL(pci.applied_to_CET,'9999-12-31') applied_to
	FROM sourceNuudlNetCrackerView.pimnrmlproductoffering_History po
	INNER JOIN sourceNuudlNetCrackerView.pimnrmlproductofferingpricechargekey_History pck ON pck.prod_offering_id = po.id
	INNER JOIN sourceNuudlNetCrackerView.pimnrmlproductofferingpricechargeitem_History pci ON pci.price_key_id = pck.id
	--WHERE po.id IN ('002d6552-2d9b-4636-9001-d1368e0c73d2','27ae1764-83d8-4f47-9b34-ca2abf66d202')
	--where po.name='3 Timer + 3 GB'
	
), products_dates AS (
	
	SELECT DISTINCT product_id, product_name, CAST(available_from as date) AS ValidFromDate FROM product_price_dates
	UNION
	SELECT DISTINCT product_id, product_name, CAST(available_to as date) AS ValidFromDate FROM product_price_dates
	UNION
	SELECT DISTINCT product_id, product_name, CAST(applied_from as date) AS ValidFromDate FROM product_price_dates
	UNION
	SELECT DISTINCT product_id, product_name, CAST(applied_to as date) AS ValidFromDate FROM product_price_dates

)

SELECT 
	ROW_NUMBER() OVER (ORDER BY ValidFromDate) ID
	,*
INTO #product_dates
FROM products_dates

;WITH product_prices AS (

	SELECT 
		po.ID,
		po.product_id,
		po.product_name,
		po.ValidFromDate,
		pci.amount,
		ps.price_type AS price_spec_price_type,
		ps.name AS price_spec_name
	FROM #product_dates po
	INNER JOIN sourceNuudlNetCrackerView.pimnrmlproductofferingpricechargekey_History pck
		ON pck.prod_offering_id = po.product_id
			AND po.ValidFromDate >= CAST(pck.available_from_CET as date)
			AND po.ValidFromDate < ISNULL( CAST(pck.available_to_CET as date), '9999-12-31' )
	INNER JOIN sourceNuudlNetCrackerView.pimnrmlproductofferingpricechargeitem_History pci
		ON pci.price_key_id = pck.id
			AND po.ValidFromDate >= CAST(pci.applied_from as date)
			AND po.ValidFromDate < ISNULL( CAST(pci.applied_to as date), '9999-12-31' )
	JOIN sourceNuudlNetCrackerView.pimnrmlprodofferingpricespecification_History ps
		ON ps.id = pck.prod_offering_price_spec_id

)
, product_prices_grouped AS (
	SELECT 
		ID,
		LAG(ID,1) OVER (PARTITION BY product_id ORDER BY ValidFromDate) PreviousID,
		ValidFromDate CalendarFromKey,
		product_id AS ProductKey,	
		MAX(CASE WHEN price_spec_price_type = 'NonRecurrent' AND price_spec_name = 'Activation Fee' THEN amount ELSE null END) ActivationBasePriceInclTax,
		MAX(CASE WHEN price_spec_price_type = 'NonRecurrent' AND price_spec_name = 'Deactivation Fee' THEN amount ELSE null END) DeactivationBasePriceInclTax,
		MAX(CASE WHEN price_spec_price_type = 'Recurrent'AND price_spec_name = 'Monthly Fee' THEN amount ELSE null END) MonthlyBasePriceInclTax
	FROM product_prices
	WHERE	1=1
	--	AND product_id = '6df1d218-9f6d-4e68-9a71-5aaff95197e5'
	--	AND product_name = 'yousee mobil 80'
	GROUP BY
		ID,
		product_id,
		product_name,
		ValidFromDate
)
, product_prices_collapsed AS (

	SELECT 
		c.*
	FROM product_prices_grouped c
	LEFT JOIN product_prices_grouped p ON p.ID = c.PreviousID
	CROSS APPLY (
		SELECT COUNT(*) Cnt
		FROM (
			SELECT c.ActivationBasePriceInclTax, c.DeactivationBasePriceInclTax, c.MonthlyBasePriceInclTax
			UNION 
			SELECT p.ActivationBasePriceInclTax, p.DeactivationBasePriceInclTax, p.MonthlyBasePriceInclTax
		) q
	) change
	WHERE Change.Cnt=2
--		AND c.ProductKey='27ae1764-83d8-4f47-9b34-ca2abf66d202'

)

INSERT INTO stage.[Fact_ProductPrices] WITH (TABLOCK) ([CalendarFromKey], [CalendarToKey], [ProductKey], [ActivationBasePriceInclTax], [DeactivationBasePriceInclTax], [MonthlyBasePriceInclTax])
SELECT 
	CalendarFromKey
	, ISNULL(DATEADD(dd,-1,LEAD(CalendarFromKey,1) OVER (PARTITION BY ProductKey ORDER BY CalendarFromKey)),'9999-12-31') CalendarToID
	, ProductKey
	, [ActivationBasePriceInclTax]
	, [DeactivationBasePriceInclTax]
	, [MonthlyBasePriceInclTax]
FROM product_prices_collapsed