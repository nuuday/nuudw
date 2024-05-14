

CREATE VIEW [cubeView_PRX].[DimProductHardware]
AS
SELECT 
	[ProductID] AS [ProductHardwareID],
	[ProductKey] AS [ProductHardwareKey],
	[ProductName] AS [ProductHardwareName],
	[ProductType] AS [ProductHardwareType]
FROM [dimView].[Product]
WHERE ProductID IN (SELECT ProductHardwareID FROM cubeView_PRX.FactOrderEvents)