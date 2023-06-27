CREATE TABLE [sourceCubus31PCTI].[BUI_915_Customers_CU] (
    [LinkKundeID]     NVARCHAR (26) NULL,
    [CustomerNumber]  DECIMAL (10)  NULL,
    [AccountNumber]   NVARCHAR (10) NULL,
    [HouseholdID]     INT           NULL,
    [Lid]             NVARCHAR (25) NULL,
    [Segment]         NVARCHAR (4)  NULL,
    [PersonId]        INT           NULL,
    [SystemKtnavn]    NVARCHAR (4)  NULL,
    [ServiceProvCode] INT           NULL,
    [Product]         NVARCHAR (20) NULL,
    [Technology]      NVARCHAR (15) NULL,
    [CVRnr]           NVARCHAR (10) NULL,
    [OKunde]          NVARCHAR (1)  NULL,
    [Objecttime]      DATETIME2 (7) NULL,
    [Kvhx]            NVARCHAR (17) NULL,
    [DWCreatedDate]   DATETIME2 (7) DEFAULT (getdate()) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_BUI_915_Customers_CU]
    ON [sourceCubus31PCTI].[BUI_915_Customers_CU];

