CREATE TABLE [stage].[Dim_Dummy] (
    [DummyKey]      NVARCHAR (300) NULL,
    [SomeAttribute] NVARCHAR (50)  NULL,
    [DWCreatedDate] DATETIME2 (0)  DEFAULT (sysdatetime()) NULL
);

