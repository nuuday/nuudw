CREATE TABLE [stage].[Dim_QuoteItem] (
    [QuoteKey]                         NVARCHAR (36)   NOT NULL,
    [QuoteItemKey]                     NVARCHAR (36)   NOT NULL,
    [QuoteItemName]                    NVARCHAR (500)  NULL,
    [NRC_ActivationBasePriceExclTax]   DECIMAL (19, 4) NULL,
    [NRC_DeactivationBasePriceExclTax] DECIMAL (19, 4) NULL,
    [NRC_DicsountPriceExclTax]         DECIMAL (38, 4) NULL,
    [NRC_ReplacementPriceExclTax]      DECIMAL (38, 4) NULL,
    [NRC_ActivationBasePriceInclTax]   DECIMAL (19, 4) NULL,
    [NRC_DeactivationBasePriceInclTax] DECIMAL (19, 4) NULL,
    [NRC_DicsountPriceInclTax]         DECIMAL (38, 4) NULL,
    [NRC_ReplacementPriceInclTax]      DECIMAL (38, 4) NULL,
    [RecurrentType]                    NVARCHAR (4000) NULL,
    [RC_BasePriceExclTax]              DECIMAL (19, 4) NULL,
    [RC_DicsountPriceExclTax]          DECIMAL (38, 4) NULL,
    [RC_ReplacementPriceExclTax]       DECIMAL (38, 4) NULL,
    [RC_BasePriceInclTax]              DECIMAL (19, 4) NULL,
    [RC_DicsountPriceInclTax]          DECIMAL (38, 4) NULL,
    [RC_ReplacementPriceInclTax]       DECIMAL (38, 4) NULL,
    [CommitmentDuration]               NVARCHAR (4000) NULL,
    [CommitmentDurationUnits]          NVARCHAR (4000) NULL,
    [DWCreatedDate]                    DATETIME2 (0)   DEFAULT (sysdatetime()) NULL
);

