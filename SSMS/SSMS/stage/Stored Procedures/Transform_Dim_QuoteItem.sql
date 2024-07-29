
CREATE PROCEDURE [stage].[Transform_Dim_QuoteItem]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_QuoteItem]

INSERT INTO [stage].[Dim_QuoteItem] (QuoteKey, [QuoteItemKey], [QuoteItemName], [NRC_ActivationBasePriceExclTax], [NRC_DeactivationBasePriceExclTax], [NRC_DicsountPriceExclTax], [NRC_ReplacementPriceExclTax], [NRC_ActivationBasePriceInclTax], [NRC_DeactivationBasePriceInclTax], [NRC_DicsountPriceInclTax], [NRC_ReplacementPriceInclTax], [RecurrentType], [RC_BasePriceExclTax], [RC_DicsountPriceExclTax], [RC_ReplacementPriceExclTax], [RC_BasePriceInclTax], [RC_DicsountPriceInclTax], [RC_ReplacementPriceInclTax], [CommitmentDuration], [CommitmentDurationUnits])
SELECT --top 100  
	quote_item.quote_id AS QuoteKey,
	quote_item.id AS QuoteItemKey,
	CONCAT(quote.number, '_', p.name) QuoteItemName,
	MAX(CASE WHEN price_spec.price_type = 'NonRecurrent' AND price_spec.name = 'Activation Fee' THEN quote_item_price.value_base_price_excluding_tax ELSE null END) NRC_ActivationBasePriceExclTax,
	MAX(CASE WHEN price_spec.price_type = 'NonRecurrent' AND price_spec.name = 'Deactivation Fee' THEN quote_item_price.value_base_price_excluding_tax ELSE null END) NRC_DeactivationBasePriceExclTax,
	MAX(CASE WHEN discount.price_alteration_type = 'DISCOUNT' AND discount.price_type = 'NRC' THEN discount.value_excluding_tax ELSE null END) NRC_DicsountPriceExclTax,
	MAX(CASE WHEN discount.price_alteration_type = 'REPLACEMENT' AND discount.price_type = 'NRC' THEN discount.value_excluding_tax ELSE null END) NRC_ReplacementPriceExclTax,
	MAX(CASE WHEN price_spec.price_type = 'NonRecurrent' AND price_spec.name = 'Activation Fee' THEN quote_item_price.value_base_price_including_tax ELSE null END) NRC_ActivationBasePriceInclTax,
	MAX(CASE WHEN price_spec.price_type = 'NonRecurrent' AND price_spec.name = 'Deactivation Fee' THEN quote_item_price.value_base_price_including_tax ELSE null END) NRC_DeactivationBasePriceInclTax,
	MAX(CASE WHEN discount.price_alteration_type = 'DISCOUNT' AND discount.price_type = 'NRC' THEN discount.value_including_tax ELSE null END) NRC_DicsountPriceInclTax,
	MAX(CASE WHEN discount.price_alteration_type = 'REPLACEMENT' AND discount.price_type = 'NRC' THEN discount.value_including_tax ELSE null END) NRC_ReplacementPriceInclTax,
	ISNULL(MAX(CASE WHEN price_spec.price_type = 'Recurrent' THEN price_spec.name ELSE null END),'?') RecurrentType,
	MAX(CASE WHEN price_spec.price_type = 'Recurrent' THEN quote_item_price.value_base_price_excluding_tax ELSE null END) RC_BasePriceExclTax,
	MAX(CASE WHEN discount.price_alteration_type = 'DISCOUNT' AND discount.price_type = 'RC' THEN discount.value_excluding_tax ELSE null END) RC_DicsountPriceExclTax,
	MAX(CASE WHEN discount.price_alteration_type = 'REPLACEMENT' AND discount.price_type = 'RC' THEN discount.value_excluding_tax ELSE null END) RC_ReplacementPriceExclTax,
	MAX(CASE WHEN price_spec.price_type = 'Recurrent' THEN quote_item_price.value_base_price_including_tax ELSE null END) RC_BasePriceInclTax,
	MAX(CASE WHEN discount.price_alteration_type = 'DISCOUNT' AND discount.price_type = 'RC' THEN discount.value_including_tax ELSE null END) RC_DicsountPriceInclTax,
	MAX(CASE WHEN discount.price_alteration_type = 'REPLACEMENT' AND discount.price_type = 'RC' THEN discount.value_including_tax ELSE null END) RC_ReplacementPriceInclTax,
	MAX(JSON_VALUE(quote_item.extended_parameters,'$.duration[0]')) CommitmentDuration,
	MAX(JSON_VALUE(quote_item.extended_parameters,'$.durationUnits[0]')) CommitmentDurationUnits
FROM sourceNuudlDawnView.qssnrmlquoteitem_History quote_item
INNER JOIN sourceNuudlDawnView.qssnrmlquote_History quote
	ON quote.id = quote_item.quote_id
		AND quote.version = quote_item.quote_version
LEFT  JOIN sourceNuudlDawnView.qssnrmlquoteitemprice_History quote_item_price
	ON quote_item_price.quote_item_id = quote_item.id
		AND quote_item_price.quote_id = quote_item.quote_id
		AND quote_item_price.quote_version = quote_item.quote_version
		AND quote_item_price.price_type IN ('NRC','RC')
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlprodofferingpricespecification_History] price_spec 
	ON price_spec.id = quote_item_price.price_specification_id
OUTER APPLY (
	SELECT
		price_alteration_type,
		price_type,
		SUM( value_including_tax ) AS value_including_tax,
		SUM( value_excluding_tax ) AS value_excluding_tax
	FROM sourceNuudlDawnView.qssnrmlquoteitempricealteration_History a
	WHERE
		a.NUUDL_IsCurrent = 1
		AND quote_item.action = 'ADD'
		AND quote_item_id = quote_item.id
		AND quote_id = quote_item.quote_id
		AND quote_version = quote_item.quote_version
		AND price_type = quote_item_price.price_type
	GROUP BY price_alteration_type, price_type
) discount
JOIN sourceNuudlDawnView.ibsnrmlproductinstance_History p
	ON p.id = quote_item.id AND p.NUUDL_IsCurrent = 1
WHERE 1=1
	AND quote_item.action <> 'DASH'
	AND quote_item.state = 'COMPLETED'
	--AND quote_item.id='4be70817-e8e4-40a8-8c36-a3f3fd7a5c31'
GROUP BY
	quote_item.quote_id,
	quote_item.id,
	p.name,
	quote.number