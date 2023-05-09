

CREATE view [meta].[ApplicationConnections] as
select 
	(case 
		when ConnectionName = 'Cube'
		then N'SSAS'
		else N'OleDb'
	end) as ConnectionType, 
	ConnectionName as Name, 
	(case
		when ConnectionName = 'Cube'
		then N'MSOLAP.5'
		else N'SQLNCLI11.1'
	end) as Provider, 
	DatabaseInstance as DataSource,
	DBSuffix as InitialCatalog,
	(case 
		when ConnectionName = 'Cube'
		then N'Data Source=' + [AnalysisServicesMultidimensionalInstance] + ';Initial Catalog=' + DBSuffix +';Provider=MSOLAP.7;Integrated Security=SSPI;'
		when ConnectionName = 'Tabular'
		then N'Data Source=' + [AnalysisServicesTabularInstance] + ';Initial Catalog=' + DBSuffix +';Provider=MSOLAP.7;Integrated Security=SSPI;'
		else N'Data Source=' + DatabaseInstance + ';Initial Catalog=' + DBSuffix + ';Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;' 
	end) as ConnectionString
from 
	meta.[Environments] as environments,
	meta.[Variables] as variables,
	(
		select (select VariableValue from meta.[Variables] where VariableName = 'DatabaseNameMeta') as DBSuffix, 'Meta' as ConnectionName union all 
		select (select VariableValue from meta.[Variables] where VariableName = 'DatabaseNameExtract'), 'Extract' union all 
		select (select VariableValue from meta.[Variables] where VariableName = 'DatabaseNameStage'), 'Stage' union all 
		select (select VariableValue from meta.[Variables] where VariableName = 'DatabaseNameDW'), 'DW' union all 
		select (select VariableValue from meta.[Variables] where VariableName = 'DatabaseNameCube'), 'Cube' union all
		select (select VariableValue from meta.[Variables] where VariableName = 'DatabaseNameTabular'), 'Tabular'
	) as DBSuffixes
where
	EnvironmentName = 'Development' and
	VariableName = 'DatabaseNameExtract'
	