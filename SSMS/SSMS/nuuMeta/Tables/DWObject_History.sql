CREATE TABLE [nuuMeta].[DWObject_History] (
    [ID]                     INT            NOT NULL,
    [DWObjectType]           NVARCHAR (30)  NOT NULL,
    [DWObjectName]           [sysname]      NOT NULL,
    [LoadPattern]            NVARCHAR (100) NOT NULL,
    [LoadProcedure]          NVARCHAR (256) NOT NULL,
    [HistoryTrackingColumns] NVARCHAR (MAX) NOT NULL,
    [ValidFrom]              DATETIME2 (7)  NOT NULL,
    [ValidTo]                DATETIME2 (7)  NOT NULL,
    [CubeSolutions]          NVARCHAR (200) NULL
);



