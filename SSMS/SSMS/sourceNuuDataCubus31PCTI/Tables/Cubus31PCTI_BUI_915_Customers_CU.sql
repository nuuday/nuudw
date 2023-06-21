CREATE TABLE [sourceNuuDataCubus31PCTI].[Cubus31PCTI_BUI_915_Customers_CU] (
    [LinkKundeID]       NVARCHAR (26) NULL,
    [CustomerNumber]    DECIMAL (10)  NULL,
    [AccountNumber]     NVARCHAR (10) NULL,
    [HouseholdID]       INT           NULL,
    [Lid]               NVARCHAR (25) NOT NULL,
    [Segment]           NVARCHAR (4)  NULL,
    [PersonId]          INT           NULL,
    [SystemKtnavn]      NVARCHAR (4)  NULL,
    [ServiceProvCode]   INT           NULL,
    [Product]           NVARCHAR (20) NOT NULL,
    [Technology]        NVARCHAR (15) NOT NULL,
    [CVRnr]             NVARCHAR (10) NULL,
    [OKunde]            NVARCHAR (1)  NULL,
    [Kvhx]              NVARCHAR (17) NULL,
    [SRC_DWCreatedDate] DATETIME2 (7) NULL,
    [DWCreatedDate]     DATETIME2 (7) DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Cubus31PCTI_BUI_915_Customers_CU] PRIMARY KEY NONCLUSTERED ([Lid] ASC, [Product] ASC, [Technology] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_Cubus31PCTI_BUI_915_Customers_CU]
    ON [sourceNuuDataCubus31PCTI].[Cubus31PCTI_BUI_915_Customers_CU];

