



CREATE FUNCTION [meta].[GetVariableValue] (
	@VariableName nvarchar(100)
)
RETURNS nvarchar(100)
AS
BEGIN
	declare @VariableValue nvarchar(100)
	select @VariableValue = VariableValue from meta.Variables where VariableName = @VariableName
	return @VariableValue
END