
CREATE VIEW [sourceNuuDataChipperView].[ChipperTicketsTickets_History]
AS
SELECT 
	[appointment.id] ,
	[assignee] ,
	[created] ,
	[customer.contact.channels.email.address] ,
	[customer.contact.channels.email.preferred] ,
	[customer.contact.channels.phone.number] ,
	[customer.contact.channels.phone.preferred] ,
	[customer.contact.name] ,
	[customer.id] ,
	[id] ,
	[impact] ,
	[issue.description] ,
	[issue.start] ,
	[issue.type] ,
	[item.lid] ,
	[reported] ,
	[resolved] ,
	[sla.id] ,
	[status] ,
	[subject] ,
	[updated] ,
	[sourceFilename] ,
	[processedTimestamp] ,
	[hour] ,
	[quarterhour] ,
	[SRC_DWSourceFilePath] ,
	[SRC_DWIsCurrent] ,
	[SRC_DWValidFromDate] ,
	[SRC_DWValidToDate] ,
	[SRC_DWCreatedDate] ,
	[SRC_DWModifiedDate] ,
	[SRC_DWIsDeletedInSource] ,
	[SRC_DWDeletedInSourceDate] ,
	[product.id] ,
	[outageid] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuuDataChipper].[ChipperTicketsTickets_History]
WHERE DWIsCurrent = 1