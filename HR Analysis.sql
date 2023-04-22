/*
HR analysis -Trevor Ali

DATA EXPLORATION & ANALYSIS - SSMS


Questions:
1. What is the Employee Count?
2. How many employee have left the company?
3. What is the rate of attrition?
4. Find the number of active employees after attrition.
5. What is the average age of employees that left the company and the gender?
6. Find the department wise attrition.
7. Number of employees by age group.
8. Find the job satisfaction rating.
9. Attrition by qualifications.
10. Find the attrition rate by gender.


*/

--------------------------------------------------------------------------------------------------------------
-- MANIPULATION
--------------------------------------------------------------------------------------------------------------
select distinct gender, count(gender)
from HRDataset
group by gender

select gender,
(case 
	when gender = 'M' then 'Male'
	when gender = 'F' then 'Female' 
	else gender
end) updated
from HRDataset

update HRDataset
set gender = 
case 
	when gender = 'M' then 'Male'
	when gender = 'F' then 'Female' 
	else gender
end
-----------------------------------------------------------------------------------------------------------

select distinct marital_status, count(marital_status)
from HRDataset
group by marital_status

select marital_status,
(case 
	when marital_status = 'M' then 'Married'
	when marital_status = 'S' then 'Single' 
	else marital_status
end) updated
from HRDataset

update HRDataset
set marital_status = 
case 
	when marital_status = 'M' then 'Married'
	when marital_status = 'S' then 'Single' 
	else marital_status
end
----------------------------------------------------------------------------------------------

select distinct attrition, count(attrition)
from HRDataset
group by attrition

select attrition,
(case 
	when attrition = 'Y' then 'Yes'
	when attrition = 'N' then 'No' 
	else attrition
end) updated
from HRDataset

update HRDataset
set attrition = 
case 
	when attrition = 'Y' then 'Yes'
	when attrition = 'N' then 'No' 
	else attrition
end
----------------------------------------------------------------------------------------------------

select education from HRDataset
-- Breakdown for Education column (separating values)
-- Method 1 SUBSTRING
Select 
	SUBSTRING(education, 1, CHARINDEX(',', education) -1) Education,
	substring(education, charindex(',', education) +2, len(education)) Education_Field
From HRDataset

-- Method 2 PARSNAME
select 
	PARSENAME(replace(education, ',' , '.'), 2) as Education,
	PARSENAME(replace(education, ',' , '.'), 1) Education_Field
from HRDataset
where education is not null

alter table HRDataset
add education2 nvarchar(255),
	education_field nvarchar(255)

update HRDataset
set education2 = PARSENAME(replace(education, ',' , '.'), 2),
	education_field = PARSENAME(replace(education, ',' , '.'), 1)

alter table HRDataset
drop column education
-----------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------
-- ANALYSIS
------------------------------------------------------------------------------------------------------

-- Q(1,2,3,4,5)
-- EEMPLOYEE COUNT, ATTRITION COUNT & RATE, ACTIVE EMPLOYEES AFTER ATTRITION and the AVERAGE AGE
WITH cte AS (
	SELECT employee_count, attrition, age,
		CASE 
			WHEN attrition = 'Yes' THEN 1
			ELSE NULL
		END AS attritions
	FROM HRAnalytics..HRDataset)
SELECT  
	sum(employee_count) EmployeeCount,
	sum(attritions) AS AttritionCount,
	round(sum(attritions) * 100.0 / count(attrition),2) AS RateOfAttrition,
	sum(employee_count)-(sum(attritions)) as ActiveEmployees,
	round(avg(age), 0) AverageAge
FROM cte
group by employee_count;


-- Q(6)
-- DEPARTMENT ATTRITION
select 
    Department, 
    count(attrition) AS AttritionCount, 
    count(attrition) * 100 / sum(count(attrition)) over () as AttritionPercent
from HRAnalytics..HRDataset
where attrition = 'Yes'
group by department
having count(attrition) > 0
order by department;


-- Q(7)
-- EMPLOYEES BY AGE GROUP
select age, sum(employee_count) EmployeeCount
from HRAnalytics..HRDataset
group by age
order by 1



-- Q(8)
-- JOB SATISFACTION MATRIX
select 
	job_role,
	sum(case when job_satisfaction = 1 then 1 else '' end) as '1',
	sum(case when job_satisfaction = 2 then 1 else '' end) as '2',
	sum(case when job_satisfaction = 3 then 1 else '' end) as '3',
	sum(case when job_satisfaction = 4 then 1 else '' end) as '4'
from HRAnalytics..HRDataset 
group by job_role



-- Q(9)
-- ATTRITION BY QUALIFICATION & FIELD
select Education, Education_Field, count(attrition) AttritionCount
from HRAnalytics..HRDataset
where attrition = 'yes'
group by education, education_field



-- Q(10)
-- ATTRITION BY AGE GROUP
select 
	Gender, 
	Age_band, 
	count(attrition) AttritionCount,
	round(cast(count(attrition) as numeric)*100/(select count(attrition) from HRAnalytics..hrdata where attrition = 'yes'),2)
from HRAnalytics..HRDataset
where attrition = 'yes'
group by gender, age_band


select * from HRAnalytics..HRDataset


-------------------------------------------------------------------------------------------------------------------

-- COMPARIN ATTRITION BY JOB SATISFACTION
select 
	job_role,
	sum(case when job_satisfaction = 1 then 1 else '' end) as '1',
	sum(case when job_satisfaction = 2 then 1 else '' end) as '2',
	sum(case when job_satisfaction = 3 then 1 else '' end) as '3',
	sum(case when job_satisfaction = 4 then 1 else '' end) as '4'
from HRAnalytics..HRDataset 
where attrition = 'yes'
group by job_role

select 
	business_travel, 
	sum(case when job_satisfaction = 1 then 1 else '' end) as '1',
	sum(case when job_satisfaction = 2 then 1 else '' end) as '2',
	sum(case when job_satisfaction = 3 then 1 else '' end) as '3',
	sum(case when job_satisfaction = 4 then 1 else '' end) as '4'
from HRAnalytics..HRDataset
where attrition = 'yes'
group by business_travel

select 
	gender, 
	sum(case when job_satisfaction = 1 then 1 else '' end) as '1',
	sum(case when job_satisfaction = 2 then 1 else '' end) as '2',
	sum(case when job_satisfaction = 3 then 1 else '' end) as '3',
	sum(case when job_satisfaction = 4 then 1 else '' end) as '4'
from HRAnalytics..HRDataset
where attrition = 'yes'
group by gender

select 
	marital_status, 
	sum(case when job_satisfaction = 1 then 1 else '' end) as '1',
	sum(case when job_satisfaction = 2 then 1 else '' end) as '2',
	sum(case when job_satisfaction = 3 then 1 else '' end) as '3',
	sum(case when job_satisfaction = 4 then 1 else '' end) as '4'
from HRAnalytics..HRDataset
where attrition = 'yes'
group by marital_status




create view hranalysis as
select 
	emp_no,
	gender,
	employee_count,
	marital_status,
	age_band, age,
	department,
	education,
	education_field,
	job_role,
	business_travel,
	attrition,
	job_satisfaction,
	active_employee
from HRAnalytics..HRDataset


select * from hranalysis
