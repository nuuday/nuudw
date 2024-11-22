
CREATE PROCEDURE [nuuMeta].[PEDataLoadLogging]

AS
DECLARE @TableName NVARCHAR(1000);
DECLARE @SQL NVARCHAR(4000);
DECLARE @Counter INT = 1;
DECLARE @TotalTables INT; 
DECLARE @TableSchema NVARCHAR(100);

Drop Table if Exists #DimTables


SELECT ROW_NUMBER() OVER (ORDER BY TABLE_NAME) AS RowNum, TABLE_NAME, TABLE_SCHEMA
INTO #DimTables
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dim' or TABLE_SCHEMA='fact'; 
-- Get the total number of tables
SET @TotalTables = (SELECT COUNT(*) FROM #DimTables); 
-- Loop through each table and get the row count
WHILE @Counter <= @TotalTables
BEGIN
-- Get the table name for the current counter
SELECT @TableName = TABLE_NAME, @TableSchema = TABLE_SCHEMA FROM #DimTables WHERE RowNum = @Counter;    
-- Construct and execute the count query for the current table
Begin Try
SET @SQL = 'Insert Into NuuMeta.PEDataLoadLog (LastLoad, NoOfRecords, TableName, Status) SELECT getDate(), COUNT(*), ''' + @TableName + ''' AS TableName, ''NULL'' FROM '+QUOTENAME(@TableSchema)+'.' + @TableName + ';';    
Exec sp_executesql @SQL;  
End Try
Begin Catch
select 1
End Catch;
-- Increment the counter
SET @Counter = @Counter + 1;
END;