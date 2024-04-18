
CREATE PROCEDURE [stage].[Transform_Dim_Employee]
	@JobIsIncremental BIT			
AS 


TRUNCATE TABLE [stage].[Dim_Employee]

INSERT INTO stage.[Dim_Employee] WITH (TABLOCK) ([EmployeeKey], [EmployeeName], [EmployeeEmail], [OrganizationalLevel1], [OrganizationalLevel2], [OrganizationalLevel3])
SELECT 
	ANUMMER AS EmployeeKey
	, Navn AS EmployeeName
	, EMAIL AS EmployeeEmail
	, substring(KONTORFORK,1,1) as OrganizationalLevel1
	, substring(KONTORFORK,1,2) as OrganizationalLevel2 
	, substring(KONTORFORK,1,3) as OrganizationalLevel3 
FROM sourceNuudlBIZView.pdindividge_History