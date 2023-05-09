

/**********************************************************************************************************************************************************************
The below script creates the a dataset with the relations between fact/bridge and dimensions. 
The script is used in the stored procedure etl.LoadFact and when fact and bridges are created throug BIML.
***********************************************************************************************************************************************************************/


CREATE PROCEDURE [meta].[CreateDWRelations]

 @Table NVARCHAR(128) 

 AS

SET NOCOUNT ON

DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')

EXEC('/*1. Create a dataset with all base dimensions--*/

						SELECT DISTINCT 
							   TABLE_NAME  AS BaseDimensionName
							  ,COLUMN_NAME AS BaseDimensionColumnName	
							  --The case statement removes the dimension name from the column in order to identity composite keys where part of the key has it own dimension
							  ,CASE 
									WHEN REPLACE(COLUMN_NAME, TABLE_NAME, '''') = ''' + @BusinessKeySuffix + ''' 
										THEN COLUMN_NAME
									ELSE REPLACE(COLUMN_NAME, TABLE_NAME, '''') 
							   END AS DimensionCompositeKeyColumnName 
							  --The last column is the column name of that comes from the fact. It only differs on the calendar dimension
							  ,COLUMN_NAME AS ColumnNameFromFact	
							  INTO #BaseDimensions
						FROM 
							[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
						
						WHERE 
							    COLUMN_NAME LIKE ''%' + @BusinessKeySuffix + '''
							AND TABLE_SCHEMA = ''dim''

										
						

/*2. Create a dataset with all fact columns*/

						
						SELECT 
							   TABLE_NAME AS FactName
							  ,COLUMN_NAME AS FactColumnName
							  INTO #FactColumns
						FROM 
							[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS

						WHERE 
							    COLUMN_NAME LIKE ''%' + @BusinessKeySuffix + '''
							AND TABLE_NAME = ''' + @Table + '''
							AND TABLE_SCHEMA = ''stage''
						

/*3. Create a dataset with all role playing dimensions*/

						
						SELECT DISTINCT
						       FactColumns.FactName
							  ,FactColumns.FactColumnName
							  ,MatchBaseAndRolePlaying.BaseDimensionName
							  ,MatchBaseAndRolePlaying.DimensionCompositeKeyColumnName 
							  ,REPLACE(
										FactColumns.FactColumnName,
										REPLACE(
											    MatchBaseAndRolePlaying.DimensionCompositeKeyColumnName,
											    MatchBaseAndRolePlaying.BaseDimensionName,
											    ''''
											    ),
										''''
									   ) AS RolePlayingDimensionName
							  --Since the rows are multiplied when joining role playing dimensions with base dimensions a row number is added to identify unique role playing dimensions 
							  ,ROW_NUMBER() OVER (
													PARTITION BY MatchBaseAndRolePlaying.BaseDimensionName 
													ORDER BY LEN(MatchBaseAndRolePlaying.BaseDimensionColumnName)
												  ) AS RowNumberUniqueRolePlayingDimensions
							  --Since the rows are multiplied when joining role playing dimensions with base dimensions a row number is added to identify unique role playing dimension keys 
							  ,ROW_NUMBER() OVER (
													PARTITION BY FactColumns.FactColumnName 
													ORDER BY CHARINDEX(REPLACE(MatchBaseAndRolePlaying.DimensionCompositeKeyColumnName,''' + @BusinessKeySuffix + ''',''''), FactColumns.FactColumnName) 
													 
													 --Substracting the number of characters from RolePlayingDimensionName columns in order to secure that only rows which holds the exact name of the roleplaying dimensions has RowN = 1
													 - LEN(REPLACE( 
																FactColumns.FactColumnName,
																REPLACE(
																		MatchBaseAndRolePlaying.DimensionCompositeKeyColumnName,
																		MatchBaseAndRolePlaying.BaseDimensionName,
																		''''
																		),
																''''
															   ) 
													) DESC
												  ) AS RowNumberRolePlayingDimensionsKeys
							INTO #RolePlayingDimensions
						FROM 
							#FactColumns AS FactColumns
						--The first join is used for removing base dimensions from the list of columns
						LEFT JOIN 
							#BaseDimensions AS BaseDimensions
								ON FactColumns.FactColumnName = BaseDimensions.ColumnNameFromFact  
						--The second join matches the role playing dimensions with the base dimensions
						INNER JOIN 
							#BaseDimensions AS MatchBaseAndRolePlaying
								ON FactColumns.FactColumnName LIKE MatchBaseAndRolePlaying.BaseDimensionName + ''%''
						WHERE 
							BaseDimensions.DimensionCompositeKeyColumnName IS NULL
							
						



/*4. Create a dataset with SCD2 dimensions*/

						
						    SELECT DISTINCT
							   tables.name AS SCD2DimensionName
							   INTO #SCD2Dimensions
							FROM
							   [' + @DatabaseNameDW + '].sys.tables
							INNER JOIN 
							   [' + @DatabaseNameDW + '].sys.all_columns 
									ON all_columns.object_id=tables.object_id
							INNER JOIN 
							   [' + @DatabaseNameDW + '].sys.extended_properties
									ON extended_properties.major_id=tables.object_id 
									AND extended_properties.minor_id=all_columns.column_id 
									AND extended_properties.class=1
							WHERE
							   extended_properties.name = ''SCDColumn''
						
						

/*5. Create a dataset with all dimensions including role playing dimensions*/


						--Base Dimensions

						SELECT DimensionCompositeKeyColumnName 
							  ,BaseDimensionColumnName
							  ,BaseDimensionName
							  ,BaseDimensionName AS BaseAndRolePlayingDimensionName
							  INTO #BaseAndRolePlayingDimensions
						FROM 
							#BaseDimensions AS BaseDimensions


						UNION

						-- Role Playing Dimensioner

						SELECT 
	  
							   CASE -- If the columnname minus the dimensionname exist in the fact the base dimension key is used
									WHEN KeyIsPartOfOtherDimension.BaseDimensionName IS NOT NULL
										THEN REPLACE(BaseDimensions.BaseDimensionColumnName ,RolePlayingDimensions.BaseDimensionName,'''') 
									-- If it is the calendar dimension the column from the fact is used
									ELSE 
										CASE 
											WHEN RolePlayingDimensions.BaseDimensionName = ''Calendar'' 
												THEN FactColumnName										
									-- Else the correct name is created from name of the role playing dimension and the base dimension key columns
											ELSE CONCAT(RolePlayingDimensions.RolePlayingDimensionName,REPLACE(BaseDimensions.BaseDimensionColumnName,RolePlayingDimensions.BaseDimensionName ,'''')) 
									    END
							   END AS DimensionCompositeKeyColumnName
							  ,BaseDimensions.BaseDimensionColumnName
							  ,RolePlayingDimensions.BaseDimensionName
							  ,RolePlayingDimensions.RolePlayingDimensionName AS BaseAndRolePlayingDimensionName
						FROM 
							#RolePlayingDimensions AS RolePlayingDimensions
						-- Der joines med basis dimensionerne for at f? r?kkerne eksploderet ud og f? de korrekte n?glekolonner
						INNER JOIN 
							#BaseDimensions AS BaseDimensions
								ON RolePlayingDimensions.BaseDimensionName = BaseDimensions.BaseDimensionName
						LEFT JOIN
							#BaseDimensions AS KeyIsPartOfOtherDimension
								ON REPLACE(BaseDimensions.BaseDimensionColumnName ,RolePlayingDimensions.BaseDimensionName,'''') = KeyIsPartOfOtherDimension.BaseDimensionColumnName
						-- Skal kun bruge de unikke Role Playing dimensioner 
						WHERE 
							RolePlayingDimensions.RowNumberRolePlayingDimensionsKeys = 1

						


--/*6. Create a dataset which maps fact/bridge and dimensions.*/

					
						SELECT DISTINCT
							   FactColumns.FactName
							  ,BaseAndRolePlayingDimensions.BaseDimensionName
							  ,CASE 
									WHEN FactColumns.FactColumnName = BaseAndRolePlayingDimensions.BaseDimensionColumnName 
										THEN BaseAndRolePlayingDimensions.BaseDimensionColumnName 
							   	    ELSE BaseAndRolePlayingDimensions.DimensionCompositeKeyColumnName 
							   END AS FactColumnName
							  ,BaseAndRolePlayingDimensions.BaseDimensionColumnName
							  ,ISNULL(RolePlayingDimensions.RolePlayingDimensionName,BaseDimensions.BaseDimensionName) AS BaseAndRolePlayingDimensionName
							  INTO #MapFactsAndDimensions
						FROM 
							#FactColumns AS FactColumns
						--First step is to match fact columns with base dimension columns. This gives us the dimension name which is used when mapping to BaseAndRolePlayingDimensions
						LEFT JOIN 
							#BaseDimensions AS BaseDimensions
								ON FactColumns.FactColumnName = BaseDimensions.ColumnNameFromFact 
						--Second step is to match the role playing dimensions to get the role playing dimension name
						LEFT JOIN 
							#RolePlayingDimensions AS RolePlayingDimensions
								ON RolePlayingDimensions.FactColumnName = FactColumns.FactColumnName
								AND RowNumberRolePlayingDimensionsKeys = 1
						--Third step is to match with the combined list of dimensions  
						LEFT JOIN 
							#BaseAndRolePlayingDimensions AS BaseAndRolePlayingDimensions
								ON ISNULL(RolePlayingDimensions.RolePlayingDimensionName,BaseDimensions.BaseDimensionName) = BaseAndRolePlayingDimensions.BaseAndRolePlayingDimensionName
						WHERE 
							BaseAndRolePlayingDimensions.BaseDimensionName IS NOT NULL

						



/*7. Create the final dataset which filter out incorrect mappings and make the final transformations.*/


						SELECT 
							   MapFactsAndDimensions.FactName
							  ,MapFactsAndDimensions.BaseDimensionName
							  ,MapFactsAndDimensions.FactColumnName
							  ,MapFactsAndDimensions.BaseDimensionColumnName
							  ,MapFactsAndDimensions.BaseAndRolePlayingDimensionName
							  --This case indicates whether a dimension is a SCD2 dimension
							  ,CASE 
									WHEN MapFactsAndDimensions.BaseDimensionName IN (SELECT SCD2DimensionName FROM #SCD2Dimensions) 
										THEN N''Yes''
									ELSE N''No'' 
							   END AS IsSCD2DimensionFlag
							  --This case indicates whether a column is part of a composite key and primary key in its own dimension which is a SCD2 dimension. Information is used in etl.LoadFact
							  ,CASE 
									WHEN REPLACE(MapFactsAndDimensions.FactColumnName,''' + @BusinessKeySuffix + ''','''') IN (SELECT SCD2DimensionName FROM #SCD2Dimensions) 
										THEN N''Yes''
									ELSE N''No'' 
							   END AS IsSCD2CompositeKeyDimensionFlag
							  --Creates a ordinal position with the correct ordering
							  ,ROW_NUMBER() OVER (
													PARTITION BY  MapFactsAndDimensions.FactName 
													ORDER BY MapFactsAndDimensions.BaseAndRolePlayingDimensionName,MapFactsAndDimensions.BaseDimensionColumnName
												  ) AS ColumnOrdinalPosition
							  --This case indicates the when a row goes from one dimension to the next. 
							  ,CASE 
									WHEN ROW_NUMBER() OVER (
															PARTITION BY MapFactsAndDimensions.BaseAndRolePlayingDimensionName 
															ORDER BY MapFactsAndDimensions.BaseAndRolePlayingDimensionName,MapFactsAndDimensions.BaseDimensionColumnName
															) = 1 
										THEN N''Yes''
									ELSE N''No'' 
							   END AS IsNewDimensionFlag
							  --This case adds the default error value to the dataset
							  ,CASE 
									WHEN MapFactsAndDimensions.BaseDimensionName = ''Calendar'' 
										THEN (SELECT CONVERT(NVARCHAR(128),value) FROM sys.extended_properties WHERE class_desc = ''DATABASE'' and name = ''DefaultDate'')
									ELSE (SELECT CONVERT(NVARCHAR(128),value) FROM sys.extended_properties WHERE class_desc = ''DATABASE'' and name = ''DefaultDimensionMemberID'')
							   END AS DefaultErrorValue
							INTO #OnlyFactColumns
						FROM 
							#MapFactsAndDimensions AS MapFactsAndDimensions
						--The last join filter out incorrect mappings
						INNER JOIN 
							#FactColumns AS FactColumns 
								ON FactColumns.FactColumnName = MapFactsAndDimensions.FactColumnName
						

/*8.Remove mappings where only part of composite key is mapped to fact like CompanyKey*/
								
		SELECT 
			FactName
		   ,BaseDimensionName
		   ,FactColumnName
		   ,BaseDimensionColumnName
		   ,BaseAndRolePlayingDimensionName
		   ,IsSCD2DimensionFlag
		   ,IsSCD2CompositeKeyDimensionFlag
		   ,ROW_NUMBER() OVER (PARTITION BY  FactName ORDER BY IsSCD2DimensionFlag,ColumnOrdinalPosition ) AS ColumnOrdinalPosition
		   ,IsNewDimensionFlag
		   ,DefaultErrorValue
		FROM 
			#OnlyFactColumns
		WHERE
			BaseDimensionName IN (SELECT DISTINCT BaseDimensionName FROM #OnlyFactColumns WHERE BaseDimensionColumnName LIKE BaseDimensionName + ''%'')
			
		DROP TABLE #OnlyFactColumns
		DROP TABLE #MapFactsAndDimensions
		DROP TABLE #FactColumns
		DROP TABLE #BaseAndRolePlayingDimensions
		DROP TABLE #RolePlayingDimensions
		DROP TABLE #BaseDimensions
		DROP TABLE #SCD2Dimensions')

SET NOCOUNT OFF