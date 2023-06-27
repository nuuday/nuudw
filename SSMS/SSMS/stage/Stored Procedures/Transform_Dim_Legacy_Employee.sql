
CREATE PROCEDURE [stage].[Transform_Dim_Legacy_Employee]
	@JobIsIncremental BIT			
AS 




/*
*** DOKUMENTATION-START **********************************************************************************

Navn: stage.Transform_Employee
Formål: Danner dimtabel med anstatte.
        Data kommer fra Cubus 21/24 og er af meget dårlig kvalitet.
		Specielt giver det problem at der er flere ansættelsesforhold pr. mearbejder samt oursourcing af medarbejdere.
		Et helt særskilt problem er at nogle medarbejdere har 2 jobs, fx. medarbejdervalgt bestyrelsesmedlemmer.
		Indlæses hver morgen.

Output: dim.Employee

Rapport Ansvarlig   : Bo Koch
Udviklet            : 2021-02-26

*** DOKUMENTATION-SLUT ***********************************************************************************
*/
		
/**********************************************************************************************************************************************************************
1. Truncate Table
***********************************************************************************************************************************************************************/

TRUNCATE TABLE [stage].[Dim_Legacy_Employee]

/**********************************************************************************************************************************************************************
2. Business Logik - Remember to use the input variable @JobIsIncremental to distinguish between full and incremental load. 
***********************************************************************************************************************************************************************/

/*Full Load pattern*/

--Vi ønsker at foretage en entydig afgrænsing af hver medarbejder pr. tidsperiode.
--Dette kompliceres af flere ansættelsesforhold pr. mearbejder samt oursourcing af medarbejdere.
DECLARE @ObjectTime DATETIME2 = GETDATE()

if  OBJECT_ID('tempdb..#Employee') is not null drop table #Employee;

CREATE TABLE #Employee
(
 Kilde                       varchar(30)
,EmployeeKey                 int NOT NULL
,FirstName                   nvarchar(30) NULL
,LastName                    nvarchar(30) NULL
,Name                        nvarchar(92) NULL
,DepartmentDescriptionShort  nvarchar(10) NULL
,Company                     nvarchar(3) NOT NULL
,UserID                      nvarchar(30) NULL
,Terminationdate             datetime
,DWIsCurrent                 bit NULL
,DWValidFromDate             datetime NOT NULL
,DWValidToDate               datetime NULL
);

create unique index #Employee_id on #Employee (employeeKey, DWValidFromDate);

if  OBJECT_ID('tempdb..#Employee_dublet_company') is not null drop table #Employee_dublet_company;
CREATE TABLE #Employee_dublet_company
(
 EmployeeId                  int NOT NULL
,DWValidFromDate             datetime NOT NULL
);

create index #Employeedubletcompany_id on #Employee_dublet_company (employeeId, DWValidFromDate);

insert into #Employee_dublet_company
select a.EmployeeID
      ,a.SRC_DW_Valid_From
from   sourceCubusMasterData.DimEmployee  a
where  EmployeeID <> 'NA'
and    EmployeeID not like 'ANONYMIZE%'
and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
and    companydescription not in ('TDC Pensionskasse')
group by a.EmployeeID
        ,a.SRC_DW_Valid_From
having count(*) > 1
order by EmployeeID

--Uden UMA, hvis skiftet fra TDC til UMA så udelades også TDC delen
insert into #Employee
SELECT 'Uden UMA'
      ,EmployeeID as EmployeeKey
      ,FirstName as EmployeeFirstName
      ,LastName as EmployeeLastName
      ,Name as EmployeeName
      ,coalesce(DepartmentDescriptionShort,'?') as EmployeeDepartmentDescriptionShort
      ,coalesce(Company,'?') as EmployeeOrganizationCode
      ,UserID as EmployeeUserCode
	  ,TerminationDate
      ,SRC_DW_IsCurrent as EmployeeIsCurrent
      ,SRC_DW_Valid_From as EmployeeValidFromDate
      ,max(SRC_DW_Valid_To) as EmployeeValidToDate
      --,case when SRC_DW_Valid_To = '9999-12-31 23:59:59.000' then '9999-12-31 23:59:59.000' else dateadd(dd,-1,SRC_DW_Valid_To) end as EmployeeValidToDate
from   sourceCubusMasterData.DimEmployee  e
where  EmployeeID <> 'NA'
and    EmployeeID not like 'ANONYMIZE%'
and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
and    companydescription not in ('TDC Pensionskasse')
and    not exists (select n.EmployeeKey
                   from   #Employee  n
				   where  n.EmployeeKey = e.EmployeeID)
and    not exists (select EmployeeID
                   from   sourceCubusMasterData.DimEmployee  h
                   where  h.sourcesystem = 'UMA'
                   and    h.EmployeeID = e.EmployeeID)
and    EmployeeID not in (select EmployeeID
                          from   #Employee_dublet_company)
group by EmployeeID
        ,FirstName
        ,LastName
        ,Name
        ,coalesce(DepartmentDescriptionShort,'?')
        ,coalesce(Company,'?')
        ,UserID
        ,TerminationDate
        ,SRC_DW_IsCurrent
        ,SRC_DW_Valid_From
order by EmployeeID
        ,EmployeeValidFromDate  desc;

--select EmployeeID, count(*)
--from   sourceCubusMasterData.DimEmployee  h
--where  not exists (select n.EmployeeKey
--                   from   #Employee  n
--				   where  n.EmployeeKey = h.EmployeeID)
--group by EmployeeID;

--Kun aktive rækker fra Cubus
truncate table #Employee_dublet_company;

insert into #Employee_dublet_company
select a.EmployeeID
      ,a.SRC_DW_Valid_From
from   sourceCubusMasterData.DimEmployee  a
where  EmployeeID <> 'NA'
and    a.EmployeeStatusDescription = 'Aktiv'
and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
and    companydescription not in ('TDC Pensionskasse')
--where  coalesce(a.EmployeeStatusDescription,'Aktiv') = 'Aktiv'
group by a.EmployeeID
        ,a.SRC_DW_Valid_From
having count(*) > 1
order by EmployeeID

--Kun aktive, hvis skiftet fra TDC til UMA så udelades UMA fordi de ikke har status = aktiv.
insert into #Employee
SELECT 'Kun aktive rækker'
      ,EmployeeID as EmployeeKey
      ,FirstName as EmployeeFirstName
      ,LastName as EmployeeLastName
      ,Name as EmployeeName
      ,coalesce(DepartmentDescriptionShort,'?') as EmployeeDepartmentDescriptionShort
      ,coalesce(Company,'?') as EmployeeOrganizationCode
      ,UserID as EmployeeUserCode
	  ,TerminationDate
      ,SRC_DW_IsCurrent as EmployeeIsCurrent
      ,SRC_DW_Valid_From as EmployeeValidFromDate
      ,max(SRC_DW_Valid_To) as EmployeeValidToDate
      --,case when SRC_DW_Valid_To = '9999-12-31 23:59:59.000' then '9999-12-31 23:59:59.000' else dateadd(dd,-1,SRC_DW_Valid_To) end as EmployeeValidToDate
from   sourceCubusMasterData.DimEmployee  e
where  EmployeeID <> 'NA'
and    e.EmployeeStatusDescription = 'Aktiv'
and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
and    companydescription not in ('TDC Pensionskasse')
and    not exists (select n.EmployeeKey
                   from   #Employee  n
				   where  n.EmployeeKey = e.EmployeeID)
and    EmployeeID not in (select EmployeeID
                          from   #Employee_dublet_company)
group by EmployeeID
        ,FirstName
        ,LastName
        ,Name
        ,coalesce(DepartmentDescriptionShort,'?')
        ,coalesce(Company,'?')
        ,UserID
        ,TerminationDate
        ,SRC_DW_IsCurrent
        ,SRC_DW_Valid_From
order by EmployeeID
        ,EmployeeValidFromDate  desc;

--select EmployeeID, count(*)
--from   sourceCubusMasterData.DimEmployee  h
--where  not exists (select n.EmployeeKey
--                   from   #Employee  n
--				   where  n.EmployeeKey = h.EmployeeID)
--group by EmployeeID;

--DECLARE @ObjectTime DATETIME2 = GETDATE()
truncate table #Employee_dublet_company;
insert into #Employee_dublet_company
select EmployeeID
      ,SRC_DW_Valid_From
from   sourceCubusMasterData.DimEmployee  e
where  EmployeeID <> 'NA'
and    (TerminationDate is null
or     TerminationDate > @ObjectTime)
and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
and    companydescription not in ('TDC Pensionskasse')
group by EmployeeID
        ,SRC_DW_Valid_From
having count(*) > 1
order by EmployeeID;

--Kun aktive, udelader alle med en historisk eller blank terminationdate
--DECLARE @ObjectTime DATETIME2 = GETDATE()
insert into #Employee
--DECLARE @ObjectTime DATETIME2 = GETDATE()
SELECT 'Historisk eller termination'
      ,EmployeeID as EmployeeKey
      ,FirstName as EmployeeFirstName
      ,LastName as EmployeeLastName
      ,Name as EmployeeName
      ,coalesce(DepartmentDescriptionShort,'?') as EmployeeDepartmentDescriptionShort
      ,coalesce(Company,'?') as EmployeeOrganizationCode
      ,UserID as EmployeeUserCode
	  ,TerminationDate
      ,SRC_DW_IsCurrent as EmployeeIsCurrent
      ,SRC_DW_Valid_From as EmployeeValidFromDate
      ,max(SRC_DW_Valid_To) as EmployeeValidToDate
from   sourceCubusMasterData.DimEmployee  e
where  EmployeeID <> 'NA'
and    e.EmployeeStatusDescription = 'Aktiv'
and   (e.TerminationDate is null
or     TerminationDate > @ObjectTime)
and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
and    companydescription not in ('TDC Pensionskasse')
and    not exists (select n.EmployeeKey
                   from   #Employee  n
				   where  n.EmployeeKey = e.EmployeeID)
and    EmployeeID not in (select EmployeeID
                          from   #Employee_dublet_company)
group by EmployeeID
        ,FirstName
        ,LastName
        ,Name
        ,coalesce(DepartmentDescriptionShort,'?')
        ,coalesce(Company,'?')
        ,UserID
        ,TerminationDate
        ,SRC_DW_IsCurrent
        ,SRC_DW_Valid_From
order by EmployeeID
        ,EmployeeValidFromDate  desc;

--select EmployeeID, count(*)
--from   sourceCubusMasterData.DimEmployee  h
--where  not exists (select n.EmployeeKey
--                   from   #Employee  n
--				   where  n.EmployeeKey = h.EmployeeID)
--group by EmployeeID;

--DECLARE @ObjectTime DATETIME2 = GETDATE()
truncate table #Employee_dublet_company;
insert into #Employee_dublet_company
select EmployeeID
      ,SRC_DW_Valid_From
from   sourceCubusMasterData.DimEmployee  e
where  EmployeeID <> 'NA'
and    e.EmployeeStatusDescription = 'Aktiv'
and   (TerminationDate is null
or     TerminationDate > @ObjectTime)
and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
and    companydescription not in ('TDC Pensionskasse')
and    EmployeeRecord in (select max(n.EmployeeRecord)
                          from   sourceCubusMasterData.DimEmployee  n
                          where  (TerminationDate is null
                          or     TerminationDate > @ObjectTime)
                          and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
                          and    companydescription not in ('TDC Pensionskasse')
						  and    n.EmployeeID = e.EmployeeID)
group by EmployeeID
        ,SRC_DW_Valid_From
having count(*) > 1
order by EmployeeID;

--Kun aktive, udelader alle med en historisk eller blank terminationdate, og seneste ansættelsesforhold
--DECLARE @ObjectTime DATETIME2 = GETDATE()
insert into #Employee
--DECLARE @ObjectTime DATETIME2 = GETDATE()
SELECT 'Seneste ansttelsesforhold'
      ,EmployeeID as EmployeeKey
      ,FirstName as EmployeeFirstName
      ,LastName as EmployeeLastName
      ,Name as EmployeeName
      ,coalesce(DepartmentDescriptionShort,'?') as EmployeeDepartmentDescriptionShort
      ,coalesce(Company,'?') as EmployeeOrganizationCode
      ,UserID as EmployeeUserCode
	  ,TerminationDate
      ,SRC_DW_IsCurrent as EmployeeIsCurrent
      ,SRC_DW_Valid_From as EmployeeValidFromDate
      ,max(SRC_DW_Valid_To) as EmployeeValidToDate
from   sourceCubusMasterData.DimEmployee  e
where  EmployeeID <> 'NA'
and    e.EmployeeStatusDescription = 'Aktiv'
and   (e.TerminationDate is null
or     TerminationDate > @ObjectTime)
and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
and    companydescription not in ('TDC Pensionskasse')
and    EmployeeRecord in (select max(n.EmployeeRecord)
                          from   sourceCubusMasterData.DimEmployee  n
                          where  (TerminationDate is null
                          or     TerminationDate > @ObjectTime)
                          and    departmentdescription not in ('AC bestyrelsesrep','Bestyrelsen','LTD bestyrelsesrep','Pensionskassen, Bestyrelse','Bestyrelsesmedlemmer & fælles')
                          and    companydescription not in ('TDC Pensionskasse')
						  and    n.EmployeeID = e.EmployeeID)
and    not exists (select n.EmployeeKey
                   from   #Employee  n
				   where  n.EmployeeKey = e.EmployeeID)
and    EmployeeID not in (select EmployeeID
                          from   #Employee_dublet_company)
group by EmployeeID
        ,FirstName
        ,LastName
        ,Name
        ,coalesce(DepartmentDescriptionShort,'?')
        ,coalesce(Company,'?')
        ,UserID
        ,TerminationDate
        ,SRC_DW_IsCurrent
        ,SRC_DW_Valid_From
order by EmployeeID
        ,EmployeeValidFromDate  desc;

--select EmployeeID, count(*)
--from   sourceCubusMasterData.DimEmployee  h
--where  not exists (select n.EmployeeKey
--                   from   #Employee  n
--				   where  n.EmployeeKey = h.EmployeeID)
--group by EmployeeID;

--Har vi nogen med flere iscurrent?
--SELECT EmployeeKey
--      ,UserID
--      ,COUNT(*)
--FROM   #Employee
--where  DWIsCurrent = 1
--group by EmployeeKey
--        ,UserID
--having COUNT(*) > 1;

--Vi nulstiller alle andre end den hvor terminatedato er null
update a
set DWIsCurrent = 0
from   #Employee  a
where  DWIsCurrent = 1
and exists (SELECT n.EmployeeKey
                  ,n.UserID
                  ,COUNT(*)
            FROM   #Employee  n
            where  n.DWIsCurrent = 1
            and    n.EmployeeKey = a.EmployeeKey
            group by n.EmployeeKey
                    ,n.UserID
            having COUNT(*) > 1)
and exists (SELECT n2.EmployeeKey
            FROM   #Employee  n2
            where  n2.DWIsCurrent = 1
            and    n2.EmployeeKey = a.EmployeeKey
            and    n2.Terminationdate is null)
and    Terminationdate is not null;

--Vi nulstiller alle andre end den nyeste terminatedato
update a
set DWIsCurrent = 0
from   #Employee  a
where  DWIsCurrent = 1
and exists (SELECT n.EmployeeKey
                  ,n.UserID
                  ,COUNT(*)
            FROM   #Employee  n
            where  n.DWIsCurrent = 1
            and    n.EmployeeKey = a.EmployeeKey
            group by n.EmployeeKey
                    ,n.UserID
            having COUNT(*) > 1)
and    Terminationdate not in (SELECT max(n2.Terminationdate)
                               FROM   #Employee  n2
                               where  n2.DWIsCurrent = 1
                               and    n2.EmployeeKey = a.EmployeeKey
                               group by n2.EmployeeKey);

CREATE TABLE #Employee2
(
 Kilde                       varchar(30)
,EmployeeKey                 int NOT NULL
,FirstName                   nvarchar(30) NULL
,LastName                    nvarchar(30) NULL
,Name                        nvarchar(92) NULL
,DepartmentDescriptionShort  nvarchar(10) NULL
,Company                     nvarchar(3) NOT NULL
,UserID                      nvarchar(30) NULL
,Terminationdate             datetime
,DWIsCurrent                 bit NULL
,DWValidFromDate             datetime NOT NULL
,DWValidToDate               datetime NULL
);

create unique index #Employee2_id on #Employee2 (employeeKey, DWValidFromDate);

insert into #Employee2
select Kilde
      ,EmployeeKey
	  ,FirstName
	  ,LastName
	  ,Name
	  ,DepartmentDescriptionShort
	  ,Company
	  ,UserID
	  ,Terminationdate
	  ,DWIsCurrent
	  ,DWValidFromDate
	  ,DWValidToDate
from   #Employee
--where  employeekey = 745498

update a
set DWValidToDate = (select MAX(b.dwvalidfromdate)
                     from   #employee  b
					 where  b.EmployeeKey = a.EmployeeKey
					 and    b.DWValidFromDate > a.DWValidFromDate)
from   #Employee2  a
where  DWValidToDate = '9999-12-31 23:59:59.000'
and    DWIsCurrent = 0

--Rettet 20220128, dubletter
delete #Employee2
--select * from #Employee2
where  Terminationdate is not null
and    Terminationdate < DWValidFromDate

--select *
--from   #Employee2
--where  employeekey = 745498
--order by DWValidFromDate

--select *
--from   #Employee2
--where  DWValidToDate = '9999-12-31 23:59:59.000'
--and    DWIsCurrent = '0'

--CREATE TABLE #Employee3
--(
-- Kilde                       varchar(30)
--,EmployeeKey                 int NOT NULL
--,FirstName                   nvarchar(30) NULL
--,LastName                    nvarchar(30) NULL
--,Name                        nvarchar(92) NULL
--,DepartmentDescriptionShort  nvarchar(10) NULL
--,Company                     nvarchar(3) NOT NULL
--,UserID                      nvarchar(30) NULL
--,Terminationdate             datetime
--,DWIsCurrent                 bit NULL
--,DWValidFromDate             datetime NOT NULL
--,DWValidToDate               datetime NULL
--);

--create unique index #Employee3_id on #Employee2 (employeeKey, DWValidFromDate);

--truncate table #Employee3
--insert into #Employee3
--select Kilde
--      ,EmployeeKey
--	  ,FirstName
--	  ,LastName
--	  ,Name
--	  ,DepartmentDescriptionShort
--	  ,Company
--	  ,UserID
--	  ,Terminationdate
--	  ,DWIsCurrent
--	  ,DWValidFromDate
--	  ,case when lead([DWValidFromDate]) over (order by employeekey, DWValidFromDate) < DWValidToDate 
--            then lead([DWValidFromDate]) over (order by employeekey, DWValidFromDate)
--            else DWValidToDate
--       end as DWValidToDate
--from   #Employee2
--where  employeekey = 745498

--select *
--from   #employee
--where  employeekey = 745498
--order by DWValidFromDate

--select *
--from   #Employee2
--where  employeekey = 745498
--order by DWValidFromDate

--select *
--from   stage.employee
--where  employeekey = 745498
--order by employeevalidfromdate

--Har alle aktive medarbejdere en employeeiscurrent?
--select *
--from   #Employee  a
--where  exists (SELECT n.EmployeeKey
--               FROM   #Employee  n
--               where  n.employeekey = A.employeekey
--               and     n.dwvalidtodate = '9999-12-31 23:59:59.000')
--and    not exists (SELECT n2.EmployeeKey
--                   FROM   #Employee  n2
--                   where  n2.employeekey = A.employeekey
--                   and     n2.DWIsCurrent = 1)
--order by employeekey
--        ,dwvalidtodate;

	--INSERT INTO stage.[Employee] WITH (TABLOCK)
	--([EmployeeKey]
 --     --,[EmployeeSourceUpdatedTS]
 --     --,[EmployeeSourceCreatedTS]
 --     --,[EmployeeSourceUpdatedBy]
 --     --,[EmployeeSourceCreatedBy]
 --     --,[EmployeeEmployeeRecord]
 --     --,[EmployeeSourceSystem]
 --     --,[EmployeeJobIndicator]
 --     --,[EmployeeEmployeeStatus]
 --     --,[EmployeeSex]
 --     --,[EmployeeBirthDate]
 --     ,[EmployeeFirstName]
 --     ,[EmployeeLastName]
 --     ,[EmployeeName]
 --     --,[EmployeeLocalPhone]
 --     --,[EmployeeMobilePhone]
 --     --,[EmployeeFAX]
 --     --,[EmployeeWorkplacePhone]
 --     --,[EmployeeAlternativePhone]
 --     --,[EmployeeRoomNumber]
 --     --,[EmployeePostalRoomNumber]
 --     --,[EmployeeEmail]
 --     ,[EmployeeUserCode]
 --     --,[EmployeeSeniorityDate]
 --     --,[EmployeeAnniversaryDate]
 --     --,[EmployeeStandardHours]
 --     --,[EmployeeOriginalHireDate]
 --     --,[EmployeeLatestHireDate]
 --     --,[EmployeeTerminationDate]
 --     --,[EmployeeLocationCode]
 --     --,[EmployeeWorkAddress]
 --     --,[EmployeeWorkZipCode]
 --     --,[EmployeeWorkPostalDistrict]
 --     --,[EmployeeBusinessTitleCode]
 --     --,[EmployeeBusinessTitle]
 --     --,[EmployeeBusinessTitleShort]
 --     --,[EmployeeBusinessStatisticsCode]
 --     --,[EmployeeBusinessFunction]
 --     --,[EmployeeJobStatus]
 --     --,[EmployeeJobCode]
 --     --,[EmployeeJobCodeDescription]
 --     --,[EmployeeEmployeeClass]
 --     --,[EmployeeSalaryAdminPlan]
 --     --,[EmployeeSalaryGrade]
 --     --,[EmployeePayGroup]
 --     --,[EmployeeSalaryType]
 --     --,[EmployeeEmployeeType]
 --     --,[EmployeeDepartmentCode]
 --     --,[EmployeeDepartmentDescription]
 --     ,[EmployeeDepartmentDescriptionShort]
 --     --,[EmployeeManagerEmployeeCode]
 --     --,[EmployeeAONR]
 --     ,[EmployeeOrganizationCode]
 --     --,[EmployeeCompanyDescription]
 --     --,[EmployeeCompanyDescriptionShort]
 --     --,[EmployeeEmployeeTypeCode]
 --     --,[EmployeeTerminationInfo]
 --     --,[EmployeeEmployeeStatusDescription]
 --     --,[EmployeeSexDescription]
 --     --,[EmployeeSkillGroup]
 --     --,[EmployeeIsManager]
 --     --,[EmployeeSquadCode]
 --     --,[EmployeeSquadDescription]
 --     --,[EmployeeSquadDescriptionShort]
 --     --,[EmployeeIsAgileCoach]
 --     --,[EmployeeIsProductOwner]
 --     --,[EmployeeApprovedEmailDomain]
 --     --,[EmployeeChapterAreaCode]
 --     --,[EmployeeChapterAreaDescription]
 --     --,[EmployeeChapterAreaDescriptionShort]
 --     ,[EmployeeIsCurrent]
 --     ,[EmployeeValidFromDate]
 --     ,[EmployeeValidToDate]
 --     ,[DWCreatedDate])

	--Apply business logic for full load here

	insert into stage.Dim_Legacy_Employee
	SELECT DISTINCT [Employeekey] as EmployeeKey
      --,[Source_Updated_TS] as EmployeeSourceUpdatedTS
      --,[Source_Created_TS] as EmployeeSourceCreatedTS
      --,[Source_Updated_By] as EmployeeSourceUpdatedBy
      --,[Source_Created_By] as EmployeeSourceCreatedBy
      --,[EmployeeRecord] as EmployeeEmployeeRecord
      ----,[SourceSystem] as EmployeeSourceSystem
      ----,[JobIndicator] as EmployeeJobIndicator
      --,[EmployeeStatus] as EmployeeEmployeeStatus
      --,[Sex] as EmployeeSex
      --,[BirthDate] as EmployeeBirthDate
      ,[FirstName] as EmployeeFirstName
      ,[LastName] as EmployeeLastName
      ,[Name] as EmployeeName
      --,[LocalPhone] as EmployeeLocalPhone
      --,[MobilePhone] as EmployeeMobilePhone
      ----,[FAX] as EmployeeFAX
      ----,[WorkplacePhone] as EmployeeWorkplacePhone
      ----,[AlternativePhone] as EmployeeAlternativePhone
      --,[RoomNumber] as EmployeeRoomNumber
      --,[PostalRoomNumber] as EmployeePostalRoomNumber
      --,[Email] as EmployeeEmail
      ,[UserID] as EmployeeUserCode
      --,[SeniorityDate] as EmployeeSeniorityDate
      --,[AnniversaryDate] as EmployeeAnniversaryDate
      --,[StandardHours] as EmployeeStandardHours
      --,[OriginalHireDate] as EmployeeOriginalHireDate
      --,[LatestHireDate] as EmployeeLatestHireDate
      ,[TerminationDate] as EmployeeTerminationDate
      --,[LocationID] as EmployeeLocationCode
      --,[WorkAddress] as EmployeeWorkAddress
      --,[WorkZipCode] as EmployeeWorkZipCode
      --,[WorkPostalDistrict] as EmployeeWorkPostalDistrict
      --,[BusinessTitleCode] as EmployeeBusinessTitleCode
      --,[BusinessTitle] as EmployeeBusinessTitle
      ----,[BusinessTitleShort] as EmployeeBusinessTitleShort
      ----,[BusinessStatisticsCode] as EmployeeBusinessStatisticsCode
      ----,[BusinessFunction] as EmployeeBusinessFunction
      --,[JobStatus] as EmployeeJobStatus
      --,[JobCode] as EmployeeJobCode
      --,[JobCodeDescription] as EmployeeJobCodeDescription
      ----,[EmployeeClass] as EmployeeEmployeeClass
      --,[SalaryAdminPlan] as EmployeeSalaryAdminPlan
      ----,[SalaryGrade] as EmployeeSalaryGrade
      ----,[PayGroup] as EmployeePayGroup
      ----,[SalaryType] as EmployeeSalaryType
      --,[EmployeeType] as EmployeeEmployeeType
      --,[DepartmentID] as EmployeeDepartmentCode
      --,[DepartmentDescription] as EmployeeDepartmentDescription
      ,case when DepartmentDescriptionShort = 'NA' then '?' else  departmentdescriptionshort end as EmployeeDepartmentDescriptionShort
      --,[ManagerEmployeeID] as EmployeeManagerEmployeeCode
      --,[AONR] as EmployeeAONR
      ,case when Company = 'NA' then '?' else Company end as EmployeeOrganizationCode
      --,[CompanyDescription] as EmployeeCompanyDescription
      --,[CompanyDescriptionShort] as EmployeeCompanyDescriptionShort
      ----,[EmployeeTypeCode] as EmployeeEmployeeTypeCode
      ----,[TerminationInfo] as EmployeeTerminationInfo
      --,[EmployeeStatusDescription] as EmployeeEmployeeStatusDescription
      --,[SexDescription] as EmployeeSexDescription
      ----,[SkillGroup] as EmployeeSkillGroup
      --,[IsManager] as EmployeeIsManager
      --,[SquadID] as EmployeeSquadCode
      --,[SquadDescription] as EmployeeSquadDescription
      --,[SquadDescriptionShort] as EmployeeSquadDescriptionShort
      --,[IsAgileCoach] as EmployeeIsAgileCoach
      --,[IsProductOwner] as EmployeeIsProductOwner
      ----,[ApprovedEmailDomain] as EmployeeApprovedEmailDomain
      --,[ChapterAreaID] as EmployeeChapterAreaCode
      --,[ChapterAreaDescription] as EmployeeChapterAreaDescription
      --,[ChapterAreaDescriptionShort] as EmployeeChapterAreaDescriptionShort
      ,[DWIsCurrent] as Legacy_EmployeeIsCurrent
      ,[DWValidFromdate] as Legacy_EmployeeValidFromDate
      ,case when DWValidToDate = '9999-12-31 23:59:59.000' then '9999-12-31 23:59:59.000' else dateadd(dd,-1,DWValidToDate) end as Legacy_EmployeeValidToDate
      ,GETDATE() as DWCreatedDate
--  INTO stage.Employee2
  FROM #Employee2