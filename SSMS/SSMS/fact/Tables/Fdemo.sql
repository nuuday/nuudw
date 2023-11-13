CREATE TABLE [fact].[Fdemo] (
    [DemoID]         INT           DEFAULT ((-1)) NOT NULL,
    [Measure]        NVARCHAR (1)  NULL,
    [DWCreatedDate]  DATETIME2 (0) NOT NULL,
    [DWModifiedDate] DATETIME2 (0) NOT NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_Fdemo]
    ON [fact].[Fdemo];

