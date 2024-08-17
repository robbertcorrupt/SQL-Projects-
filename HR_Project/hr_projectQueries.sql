Create schema hr_project;
use hr_project ;
CREATE TABLE hr1 (
    Age INT,
    Attrition VARCHAR(255),
    BusinessTravel VARCHAR(255),
    DailyRate INT,
    Department VARCHAR(255),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(255),
    EmployeeCount INT,
    EmployeeNumber INT,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(255),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(255),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(255)
);
Select * from hr1;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/hr_project/HR_1.csv' into table hr1 
fields terminated by ','
ignore 1 lines ;

CREATE TABLE hr2 (
    EmployeeID INT,
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(2),
    OverTime VARCHAR(3),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/hr_project/HR_2.csv' into table hr2
fields terminated by ','
ignore 1 lines ;

-- 1 . Average attrition rate - Department Wise.

SELECT
    Department,
    format(avg(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)*100,2) AS AttritionRate
FROM
    hr1
GROUP BY
    Department;
   
-- 2 . Average Hourly Rate Male Research Scientist.

select 
    format(avg(HourlyRate),2) as AveragehourlyRate
from hr1
where Gender = "Male" and JobRole = "Research Scientist" ;

-- 3 . Averge Working Years - Department Wise.

select 
	hr1.Department , format(avg(hr2.TotalWorkingYears),2) as AverageWorkingYears
from 
    hr1
join 
	hr2 on hr1.EmployeeNumber = hr2.EmployeeID
group by 
     Department ;
     
-- 4 . Job Role vs Work Life Balance

select 
    hr2.WorkLifeBalance , hr1.JobRole , count(hr2.EmployeeID) as EmployeeCount
from 
     hr2
join hr1 
    on hr1.EmployeeNumber = hr2.EmployeeID 
group by 
    hr2.WorkLifeBalance , hr1.JobRole
order by 
    hr2.WorkLifeBalance desc ;
    
-- 5 . Attrition Rate vs Year since Last Promotion

select
      hr1.department , format(avg(hr2.YearsSinceLastPromotion),2) as AverageYearsSinceLastPromotion
from
      hr1
join  hr2 
   on hr1.EmployeeNumber = hr2.EmployeeID 
group by 
	  hr1.Department ;

-- 6 . Attrition Rate vs Monthly Income

select
       hr1.Gender , format(avg(hr2.MonthlyIncome),0) as AverageMonthlyIncome , 
       sum(CASE WHEN hr1.Attrition = 'Yes' THEN 1 ELSE 0 END) as AttritionRate
from 
       hr1
join   hr2 
on     hr1.EmployeeNumber = hr2.EmployeeID 
group by
       hr1.gender ;









