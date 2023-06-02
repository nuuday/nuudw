
CREATE VIEW [sourceCubusBivodView].[OTT_STREAMLOG_History]
AS
SELECT 
	[ID] ,
	[LOG_ID] ,
	[STREAMED_AT] ,
	[CUSTOMER_NUMBER] ,
	[CONTENT_ID] ,
	[CONTENT_TYPE] ,
	[CONTENT_DESCRIPTION] ,
	[CLIENT_TYPE] ,
	[CLIENT_UID] ,
	[IP] ,
	[YOUSEE_IP] ,
	[CUSTOMER_ORIGIN] ,
	[PRODUCT_TYPE] ,
	[STREAM_START] ,
	[STREAM_END] ,
	[IMPORT_DATE] ,
	[PERSONA] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceCubusBivod].[OTT_STREAMLOG_History]
WHERE DWIsCurrent = 1