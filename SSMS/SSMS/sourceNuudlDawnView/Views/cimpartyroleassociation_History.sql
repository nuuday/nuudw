﻿
CREATE VIEW [sourceNuudlDawnView].[cimpartyroleassociation_History]
AS
SELECT 
	[active_from] ,
	[association_name] ,
	[association_role] ,
	[changed_by] ,
	[id] ,
	[id_from] ,
	[id_to] ,
	[op] ,
	[ref_type_from] ,
	[ref_type_to] ,
	[ts_ms] ,
	[Snapshot] ,
	[Partition_Snapshot] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_ID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlDawn].[cimpartyroleassociation_History]
WHERE DWIsCurrent = 1