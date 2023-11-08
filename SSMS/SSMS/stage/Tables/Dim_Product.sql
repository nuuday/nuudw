CREATE TABLE [stage].[Dim_Product] (
    [ProductKey]    NVARCHAR (36)  NULL,
    [ProductName]   NVARCHAR (250) NULL,
    [ProductType]   NVARCHAR (50)  NULL,
    [ProductWeight] NVARCHAR (3)   NULL,
    [DWCreatedDate] DATETIME       NOT NULL
);



