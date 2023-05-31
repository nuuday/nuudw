﻿CREATE TABLE [sourceCubusBivod].[VIDEO_METADATA] (
    [id]                         INT             NOT NULL,
    [updated]                    DATETIME        NULL,
    [ASSET_ID]                   NVARCHAR (50)   NULL,
    [LANGUAGE]                   NVARCHAR (3)    NULL,
    [METADATA_CREATED]           DATE            NULL,
    [PROVIDER_ID]                NVARCHAR (128)  NULL,
    [PROVIDER_NAME]              NVARCHAR (128)  NULL,
    [TITLE]                      NVARCHAR (1024) NULL,
    [TITLE_SYNOPSIS]             NVARCHAR (2048) NULL,
    [RATING]                     NVARCHAR (32)   NULL,
    [RUN_TIME]                   INT             NULL,
    [DISPLAY_RUN_TIME]           NVARCHAR (8)    NULL,
    [PRODUCTION_YEAR]            INT             NULL,
    [COUNTRY_OF_ORIGIN]          NVARCHAR (128)  NULL,
    [IMDB_ID]                    NVARCHAR (16)   NULL,
    [ACTORS]                     NVARCHAR (2048) NULL,
    [WRITERS]                    NVARCHAR (2048) NULL,
    [DIRECTORS]                  NVARCHAR (2048) NULL,
    [CATEGORY]                   NVARCHAR (32)   NULL,
    [GENRES]                     NVARCHAR (1024) NULL,
    [LICENSING_WINDOW_START]     DATETIME2 (7)   NULL,
    [LICENSING_WINDOW_END]       DATETIME2 (7)   NULL,
    [ALLOWED_FOR_PUBLIC_VIEWING] TINYINT         NULL,
    [VIDEOPRODUCTS]              NVARCHAR (1024) NULL,
    [EPISODE_NAME]               NVARCHAR (1024) NULL,
    [EPISODE_NUMBER]             NVARCHAR (32)   NULL,
    [SERIES_NAME]                NVARCHAR (1024) NULL,
    [SERIES_SYNOPSIS]            NVARCHAR (2048) NULL,
    [SEASON_NAME]                NVARCHAR (1024) NULL,
    [SEASON_SYNOPSIS]            NVARCHAR (2048) NULL,
    [SEASON_NUMBER]              NVARCHAR (32)   NULL,
    [MEDIAID]                    NVARCHAR (255)  NULL,
    [EXTERNALID]                 NVARCHAR (100)  NULL,
    [EPISODE_ID]                 NVARCHAR (100)  NULL,
    [COVER_URL]                  NVARCHAR (200)  NULL,
    [DWCreatedDate]              DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_VIDEO_METADATA] PRIMARY KEY NONCLUSTERED ([id] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_VIDEO_METADATA]
    ON [sourceCubusBivod].[VIDEO_METADATA];

