CREATE TABLE [stage].[Fact_ProductPrices] (
    [CalendarFromKey]              DATE            NOT NULL,
    [CalendarToKey]                DATE            NULL,
    [ProductKey]                   NVARCHAR (36)   NULL,
    [ActivationBasePriceInclTax]   DECIMAL (19, 4) NULL,
    [DeactivationBasePriceInclTax] DECIMAL (19, 4) NULL,
    [MonthlyBasePriceInclTax]      DECIMAL (19, 4) NULL,
    [DWCreatedDate]                DATETIME2 (0)   DEFAULT (sysdatetime()) NULL
);

