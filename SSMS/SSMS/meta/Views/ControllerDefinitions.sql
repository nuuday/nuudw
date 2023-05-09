











CREATE VIEW [meta].[ControllerDefinitions] AS

WITH ParentChildData AS
 (
SELECT TableName
	  ,DestinationSchema
	  ,CASE 
			WHEN Child.ChildBusinessMatrixID IS NULL AND Parent.ChildBusinessMatrixID IS NOT NULL THEN BusinessMatrix.ID
			WHEN Child.ChildBusinessMatrixID IS NOT NULL AND Parent.ChildBusinessMatrixID IS NOT NULL THEN Child.ChildBusinessMatrixID
			WHEN Child.ChildBusinessMatrixID IS NOT NULL AND Parent.ChildBusinessMatrixID IS NULL THEN Child.ChildBusinessMatrixID
			ELSE BusinessMatrix.ID
	   END AS ChildBusinessMatrixID
	  ,CASE 
			WHEN Child.ChildBusinessMatrixID IS NULL AND Parent.ChildBusinessMatrixID IS NOT NULL THEN NULL
			WHEN Child.ChildBusinessMatrixID IS NOT NULL AND Parent.ChildBusinessMatrixID IS NOT NULL THEN Child.ParentBusinessMatrixID
			WHEN Child.ChildBusinessMatrixID IS NOT NULL AND Parent.ChildBusinessMatrixID IS NULL THEN Child.ParentBusinessMatrixID
			ELSE BusinessMatrix.ID
	   END AS ParentBusinessMatrixID
    
  FROM 
		meta.BusinessMatrix
  LEFT JOIN 
		meta.BusinessMatrixPackageDependency AS Child
			ON Child.ChildBusinessMatrixID = BusinessMatrix.ID
  LEFT JOIN 
		meta.BusinessMatrixPackageDependency AS Parent
			ON Parent.ParentBusinessMatrixID = BusinessMatrix.ID
  WHERE 
	BusinessMatrix.PackageDependencyFlag = 1
	AND ControllerExcludeFlag = 0

							)

, RecursiveHierarchy
AS
(
 SELECT 
		ChildBusinessMatrixID AS BusinessMatrixID
	   ,DestinationSchema
	   ,TableName
	   ,1 AS Generation
	   ,ParentBusinessMatrixID AS ParentID
 FROM 
	ParentChildData AS FirtGeneration
 WHERE 
	ParentBusinessMatrixID IS NULL 
	       
 UNION ALL

 SELECT 
		NextGeneration.ChildBusinessMatrixID
	   ,NextGeneration.DestinationSchema
	   ,NextGeneration.TableName
	   ,Parent.Generation + 1
	   ,Parent.BusinessMatrixID
 FROM 
	ParentChildData AS NextGeneration
 INNER JOIN 
	RecursiveHierarchy AS Parent 
		ON NextGeneration.ParentBusinessMatrixID = Parent.BusinessMatrixID     
)

, DistinctHierarchyData AS
(
SELECT DISTINCT  *
FROM 
	RecursiveHierarchy
	)

,TopLevelParent AS
(
SELECT 
	   BusinessMatrixID
	  ,DestinationSchema
	  ,TableName
	  ,Generation
	  ,ParentID
	  ,BusinessMatrixID AS TopLevelParent
	FROM 
		DistinctHierarchyData
	WHERE 
		ParentID IS NULL

  UNION ALL

SELECT DistinctHierarchyData.*
	  ,TopLevelParent.TopLevelParent 
FROM 
	DistinctHierarchyData
INNER JOIN
	TopLevelParent 
		ON TopLevelParent.BusinessMatrixID = DistinctHierarchyData.ParentID
WHERE 
	DistinctHierarchyData.BusinessMatrixID <> DistinctHierarchyData.ParentID
)

, PackageDependencies AS

(

SELECT DISTINCT
	    TopLevelParent.BusinessMatrixID
	   ,TopLevelParent.DestinationSchema
	   ,TopLevelParent.TableName
	   ,CAST(TopLevelParent.Generation AS NVARCHAR(10)) AS Generation
	   ,N'Dependencies' AS TopLevelName

FROM
	TopLevelParent
INNER JOIN
	meta.BusinessMatrix
		ON BusinessMatrix.ID = TopLevelParent.TopLevelParent
LEFT JOIN
	meta.BusinessMatrix AS Parent
		ON Parent.ID = TopLevelParent.ParentID


UNION ALL

SELECT	
	   ID
	  ,DestinationSchema
	  ,TableName
	  ,N'0'
	  ,'NoDependencies'


FROM 
	meta.BusinessMatrix
WHERE 
	ID NOT IN (SELECT BusinessMatrixID FROM RecursiveHierarchy)
	AND ControllerExcludeFlag = 0
	)


,ControllerData AS
(
SELECT 
	  SourceObjects.ID
	, 'Controller_Extract' + (CASE WHEN ConnectionType in ('Excel','FlatFile') THEN ConnectionType ELSE [Name] END) AS ControllerName
	, ExtractSchemaName AS SchemaName
	, N'Extract' AS ControllerArea
	, SourceObjects.ObjectName AS TableName
	, 'Extract' + ExtractSchemaName + '_' + ObjectName AS PackageName
	, ControllerExcludeFlag
	, '0' AS Generation
	, 'Extract' AS TopLevelName
	, FrameworkMetaData.AverageDuration
	, NULL AS ParentPackageDependencyName
	, NULL AS ParentPackageDependencyPackageName
	, 0 AS PackageDependencyFlag
		
FROM 
	meta.SourceConnections
INNER JOIN
	meta.SourceObjects
		ON SourceObjects.SourceConnectionID = SourceConnections.ID
LEFT JOIN
	meta.FrameworkMetaData
		ON FrameworkMetaData.SourceObjectID = SourceObjects.ID
WHERE
	DWDestinationFlag = 1
	AND SourceConnections.ExcludeFlag = 0

UNION

SELECT 
	  TargetObjects.ID
	, 'Controller_Extract_' + SourceConnections.[Name] + '_' + (CASE WHEN TargetConnections.ConnectionType in ('Excel','FlatFile') THEN TargetConnections.ConnectionType ELSE TargetConnections.[Name] END) AS ControllerName
	, ExtractSchemaName AS SchemaName
	, N'Extract' AS ControllerArea
	, SourceObjects.ObjectName AS TableName
	, 'Extract' + SourceConnections.Name + '_'+ TargetConnections.Name + '_' +  IIF(TargetObjects.FileTargetFlag = 1, TargetObjectFileSetup.FileSystemName + '_' + REPLACE(TargetObjectFileSetup.FolderName, '/', '') + '_','') + SourceObjects.ObjectName AS PackageName
	, TargetObjects.ControllerExcludeFlag
	, '0' AS Generation
	, 'Target' AS TopLevelName
	, NULL AS AverageDuration
	, NULL AS ParentPackageDependencyName
	, NULL AS ParentPackageDependencyPackageName
	, 0 AS PackageDependencyFlag
		
FROM 
	meta.TargetConnections
INNER JOIN
	meta.TargetObjects
		ON TargetObjects.TargetConnectionID = TargetConnections.ID
INNER JOIN
	meta.SourceObjects
		ON SourceObjects.ID = TargetObjects.SourceObjectID
INNER JOIN
	meta.SourceConnections
		ON SourceConnections.ID = SourceObjects.SourceConnectionID
LEFT JOIN
	meta.TargetObjectFileSetup
		ON TargetObjectFileSetup.TargetObjectID = TargetObjects.ID
WHERE
	TargetConnections.ExcludeFlag = 0

UNION 

SELECT 
	  BusinessMatrix.ID
	, 'Controller_Load' + CASE BusinessMatrix.DestinationSchema
								WHEN 'dim' THEN 'Dimensions'
								WHEN 'bridge' THEN 'Bridges'
								WHEN 'fact' THEN 'Facts'
								WHEN 'temp' THEN 'Temp'
								ELSE ''
						 END
	, BusinessMatrix.DestinationSchema
	, CASE BusinessMatrix.DestinationSchema
								WHEN 'dim' THEN 'Dimensions'
								WHEN 'bridge' THEN 'Bridges'
								WHEN 'fact' THEN 'Facts'
								WHEN 'temp' THEN 'Temp'
								ELSE ''
	  END
	, IIF(BusinessMatrix.DestinationSchema = 'temp','Temp_','') + BusinessMatrix.TableName
	, CASE BusinessMatrix.DestinationSchema
								WHEN 'dim' THEN 'LoadDimension_'
								WHEN 'bridge' THEN 'LoadBridge_'
								WHEN 'fact' THEN 'LoadFact_'
								ELSE 'Transform_'
			   END + BusinessMatrix.TableName
	, BusinessMatrix.ControllerExcludeFlag
	, PackageDependencies.Generation
	, PackageDependencies.TopLevelName
	, FrameworkMetaData.AverageDuration
	, Parent.TableName
	, CASE BusinessMatrix.DestinationSchema
								WHEN 'dim' THEN 'LoadDimension_'
								WHEN 'bridge' THEN 'LoadBridge_'
								WHEN 'fact' THEN 'LoadFact_'
								ELSE 'Transform_'
      END + Parent.TableName
	, BusinessMatrix.PackageDependencyFlag
FROM
	meta.BusinessMatrix
INNER JOIN
	PackageDependencies
		ON PackageDependencies.BusinessMatrixID = BusinessMatrix.ID
LEFT JOIN
	meta.FrameworkMetaData
		ON FrameworkMetaData.BusinessMatrixID = BusinessMatrix.ID
LEFT JOIN
	meta.BusinessMatrixPackageDependency
		ON BusinessMatrix.ID = BusinessMatrixPackageDependency.ChildBusinessMatrixID
LEFT JOIN
	meta.BusinessMatrix AS Parent
		ON Parent.ID = BusinessMatrixPackageDependency.ParentBusinessMatrixID

)

, Controller AS
(
SELECT 
	  ID
	, ControllerName
	, SchemaName
	, ControllerArea
	, TableName
	, PackageName
	, ControllerData.ControllerExcludeFlag
	, Generation
	, CAST(Generation - 1 AS NVARCHAR(10)) AS PrevGeneration
	, TopLevelName
	, CAST(PackageDependencyFlag AS NVARCHAR(1)) AS HasDependencyFlag
	, IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName) AS ParentPackageDependencyName
	, IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyPackageName) AS ParentPackageDependencyPackageName
	, ISNULL(AverageDuration,1) AS AverageDuration
	, CAST(ROW_NUMBER() OVER (PARTITION BY ControllerName,Generation,ISNULL( IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName),'') ORDER BY ControllerData.ID) AS NVARCHAR(4000)) AS RowNo
	, CAST(ROW_NUMBER() OVER (PARTITION BY ControllerName,Generation,ISNULL( IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName),'') ORDER BY ControllerData.ID) - 1 AS NVARCHAR(4000)) AS PrevRowNo
	, CAST(ROW_NUMBER() OVER (PARTITION BY ControllerName,Generation,ISNULL( IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName),'') ORDER BY ControllerData.ID) - 2 AS NVARCHAR(4000)) AS PrevPrevRowNo
	--, IIF((ROW_NUMBER() OVER (PARTITION BY ControllerName,Generation,ISNULL( IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName),'') ORDER BY ControllerData.ID) % 2) = 0,'1','0') AS IsEvenFlag
	, IIF(SchemaName IN ('dim','bridge','fact'),'1','0') AS IsLoadFlag 
	, CASE 
		   WHEN ControllerArea = 'Extract' THEN (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'ExtractControllerPattern')
		   ELSE (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'LoadControllerPattern')
	  END AS ControllerPattern
	, (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta') AS DatabaseName
	, 0 AS IsTransformFlag
FROM 
	ControllerData
WHERE
	ControllerExcludeFlag = 0
	

UNION

SELECT 
	  ID
	, ControllerName
	, SchemaName
	, ControllerArea
	, TableName
	, 'Transform_' + TableName AS PackageName
	, ControllerData.ControllerExcludeFlag
	, Generation
	, CAST(Generation - 1 AS NVARCHAR(10)) AS PrevGeneration
	, TopLevelName
	, CAST(PackageDependencyFlag AS NVARCHAR(1)) AS HasDependencyFlag
	, IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName) AS ParentPackageDependencyName
	, IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyPackageName) AS ParentPackageDependencyPackageName
	, ISNULL(AverageDuration,1) AS AverageDuration
	, CAST(ROW_NUMBER() OVER (PARTITION BY ControllerName,Generation,ISNULL( IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName),'') ORDER BY ControllerData.ID) AS NVARCHAR(4000)) AS RowNo
	, CAST(ROW_NUMBER() OVER (PARTITION BY ControllerName,Generation,ISNULL( IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName),'') ORDER BY ControllerData.ID) - 1 AS NVARCHAR(4000)) AS PrevRowNo
	, CAST(ROW_NUMBER() OVER (PARTITION BY ControllerName,Generation,ISNULL( IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName),'') ORDER BY ControllerData.ID) - 2 AS NVARCHAR(4000)) AS PrevPrevRowNo
	--, IIF((ROW_NUMBER() OVER (PARTITION BY ControllerName,Generation,ISNULL( IIF(PackageDependencyFlag = 0,NULL,ParentPackageDependencyName),'') ORDER BY ControllerData.ID) % 2) = 0,'1','0') AS IsEvenFlag
	, 0 AS IsLoadFlag 
	, CASE 
		   WHEN ControllerArea = 'Extract' THEN (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'ExtractControllerPattern')
		   ELSE (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'LoadControllerPattern')
	  END AS ControllerPattern
	, (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta') AS DatabaseName
	, 1 AS IsTransformFlag
FROM 
	ControllerData
WHERE
	ControllerExcludeFlag = 0
	AND SchemaName IN ('dim','bridge','fact')
	AND TableName NOT IN ('Calendar','Time')
	)


SELECT  *
	   ,ControllerName + CASE
							WHEN ControllerArea NOT IN ('Extract','Temp') THEN 
																				CASE
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) <= 20 THEN ''
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 21 AND 40 THEN '1'
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 41 AND 60 THEN '2'
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 61 AND 80 THEN '3'
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 81 AND 100 THEN '4'
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 101 AND 120 THEN '5'
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 121 AND 140 THEN '6'
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 141 AND 160 THEN '7'
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 161 AND 180 THEN '8'
																					WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName, Generation) BETWEEN 181 AND 200 THEN '9'
																					ELSE '10'
																				END
							ELSE CASE
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) <= 40 THEN ''
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 41 AND 80 THEN '1'
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 81 AND 120 THEN '2'
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 121 AND 160 THEN '3'
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 161 AND 200 THEN '4'
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 201 AND 240 THEN '5'
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 241 AND 280 THEN '6'
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 281 AND 320 THEN '7'
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 321 AND 360 THEN '8'
									WHEN DENSE_RANK() OVER (PARTITION BY ControllerName ORDER BY TableName) BETWEEN 361 AND 400 THEN '9'
									ELSE '10'
								END
						   END AS CloudControllerName
		
FROM Controller










