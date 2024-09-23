
CREATE VIEW [martView_PRX].[DimQuoteItem]
AS
SELECT 
	[QuoteItemID],
	[QuoteKey],
	[QuoteItemKey],
	[QuoteItemName],
	[NRC_ActivationBasePriceExclTax],
	[NRC_DeactivationBasePriceExclTax],
	[NRC_DicsountPriceExclTax],
	[NRC_ReplacementPriceExclTax],
	[NRC_ActivationBasePriceInclTax],
	[NRC_DeactivationBasePriceInclTax],
	[NRC_DicsountPriceInclTax],
	[NRC_ReplacementPriceInclTax],
	[RecurrentType],
	[RC_BasePriceExclTax],
	[RC_DicsountPriceExclTax],
	[RC_ReplacementPriceExclTax],
	[RC_BasePriceInclTax],
	[RC_DicsountPriceInclTax],
	[RC_ReplacementPriceInclTax],
	[CommitmentDuration],
	[CommitmentDurationUnits],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[QuoteItem]