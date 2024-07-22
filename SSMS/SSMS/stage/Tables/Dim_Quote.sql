CREATE TABLE [stage].[Dim_Quote] (
    [QuoteKey]      NVARCHAR (10) NULL,
    [DWCreatedDate] DATETIME2 (0) DEFAULT (sysdatetime()) NOT NULL
);



