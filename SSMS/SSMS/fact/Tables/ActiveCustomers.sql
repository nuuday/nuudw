CREATE TABLE [fact].[ActiveCustomers] (
    [CalendarID]               INT           DEFAULT ((-1)) NOT NULL,
    [ActiveCustomersCountDate] DATE          NULL,
    [ActiveCustomersCount]     INT           NULL,
    [DWCreatedDate]            DATETIME2 (0) NOT NULL,
    [DWModifiedDate]           DATETIME2 (0) NOT NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ActiveCustomers]
    ON [fact].[ActiveCustomers];

