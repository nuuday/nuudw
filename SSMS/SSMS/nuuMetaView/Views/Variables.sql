
CREATE VIEW [nuuMetaView].[Variables] AS

SELECT 
	 CONVERT(NVARCHAR(128),Name) AS VariableName
	,CONVERT(NVARCHAR(128),value) AS VariableValue
	,'EXEC sp_updateextendedproperty @name = N''' + CONVERT(NVARCHAR(128),Name) + ''', @value = N''' + CONVERT(NVARCHAR(128),value) + '''' AS UpdateVariableSQL
FROM 
	sys.extended_properties 
WHERE 
	class_desc = 'DATABASE'