CREATE TABLE [fact].[ProductPrices_Temp] (
    [CalendarFromID]               INT             DEFAULT ((-1)) NOT NULL,
    [CalendarToID]                 INT             DEFAULT ((-1)) NOT NULL,
    [ProductID]                    INT             DEFAULT ((-1)) NOT NULL,
    [ActivationBasePriceInclTax]   DECIMAL (19, 4) NULL,
    [DeactivationBasePriceInclTax] DECIMAL (19, 4) NULL,
    [MonthlyBasePriceInclTax]      DECIMAL (19, 4) NULL,
    [DWCreatedDate]                DATETIME2 (0)   NOT NULL,
    [DWModifiedDate]               DATETIME2 (0)   NOT NULL
);

