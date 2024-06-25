CREATE TABLE [sourceNuudlNetCracker].[ibsitemshistory_History_Filter] (
    [id]           NVARCHAR (36) NOT NULL,
    [DWCreateDate] DATETIME2 (0) DEFAULT (sysdatetime()) NULL,
    CONSTRAINT [PK_ibsitemshistory_History_Filter] PRIMARY KEY NONCLUSTERED ([id] ASC)
);

