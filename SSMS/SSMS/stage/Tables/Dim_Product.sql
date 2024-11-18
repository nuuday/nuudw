CREATE TABLE [stage].[Dim_Product] (
    [ProductKey]    NVARCHAR (36)  NULL,
    [ProductName]   NVARCHAR (250) NULL,
    [ProductType]   NVARCHAR (50)  NULL,
    [ProductWeight] INT   NULL,
    [DWCreatedDate] DATETIME2 (0)  DEFAULT (sysdatetime()) NOT NULL
);





