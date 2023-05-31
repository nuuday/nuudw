﻿
CREATE VIEW [sourceCubusBivodView].[VIDEO_METADATA_History]
AS
SELECT 
	[id] ,
	[updated] ,
	[ASSET_ID] ,
	[LANGUAGE] ,
	[METADATA_CREATED] ,
	[PROVIDER_ID] ,
	[PROVIDER_NAME] ,
	[TITLE] ,
	[TITLE_SYNOPSIS] ,
	[RATING] ,
	[RUN_TIME] ,
	[DISPLAY_RUN_TIME] ,
	[PRODUCTION_YEAR] ,
	[COUNTRY_OF_ORIGIN] ,
	[IMDB_ID] ,
	[ACTORS] ,
	[WRITERS] ,
	[DIRECTORS] ,
	[CATEGORY] ,
	[GENRES] ,
	[LICENSING_WINDOW_START] ,
	[LICENSING_WINDOW_END] ,
	[ALLOWED_FOR_PUBLIC_VIEWING] ,
	[VIDEOPRODUCTS] ,
	[EPISODE_NAME] ,
	[EPISODE_NUMBER] ,
	[SERIES_NAME] ,
	[SERIES_SYNOPSIS] ,
	[SEASON_NAME] ,
	[SEASON_SYNOPSIS] ,
	[SEASON_NUMBER] ,
	[MEDIAID] ,
	[EXTERNALID] ,
	[EPISODE_ID] ,
	[COVER_URL] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceCubusBivod].[VIDEO_METADATA_History]
WHERE DWIsCurrent = 1