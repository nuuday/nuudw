CREATE TABLE [stage].[Dim_OrderEvent] (
    [OrderEventKey]   NVARCHAR (3)  NULL,
    [OrderEventName]  NVARCHAR (50) NULL,
    [SourceEventName] NVARCHAR (50) NULL,
    [DWCreatedDate]   DATETIME2 (0) DEFAULT (getdate()) NULL
);

