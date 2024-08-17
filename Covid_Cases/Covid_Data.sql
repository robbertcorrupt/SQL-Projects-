create table Covid_data(State_UTs text, Total_Cases integer, Active integer,
	Discharged integer, Deaths integer, Active_Ratio numeric,
	Discharge_Ratio numeric, Death_Ratio numeric, Population
    integer)
copy covid_data FROM 'D:/Backup data/C drive/Downloads/Latest Covid-19 India Status.csv' DELIMITER ',' CSV HEADER ENCODING 'WIN1252';
Select * from Covid_data

-----Queries------

--1. states with most active cases

Select state_uts, active as Active_cases
from covid_data
group by state_uts, active
order by active desc limit 10

--2.states with successful discharges
Select state_uts, discharged as Discharges
from covid_data
group by state_uts, discharges
order by Discharges desc limit 10

--3.states with most 10 deaths
Select 
state_uts as State_UTs,
deaths as Deaths
from Covid_data
group by state_uts, deaths
order by deaths desc
limit 10

--4.Compute the Discharge Rate

select * from (
Select 
state_uts as State_UTs,
discharged as Discharged_Cases,
total_cases as Total_Cases,
round(100*(round(discharged,2)/round(total_cases,2)),2) as Discharge_Ratio_Calculated
from Covid_data
group by state_uts,discharged,total_cases,deaths
order by deaths desc
limit 10
) a

order by a.discharge_ratio_Calculated desc

--5.Max Total_Case vs Min Total_Case

SELECT 
    MIN_TABLE.State_uts AS State_with_Minimum_cases,
    MIN_TABLE.Minimum_cases,
    MAX_TABLE.State_uts AS State_with_Maximum_cases,
    MAX_TABLE.Maximum_cases
FROM 
    (SELECT 
        State_uts, 
        MIN(total_cases) AS Minimum_cases
     FROM 
        covid_data
     GROUP BY 
        State_uts
     ORDER BY 
        Minimum_cases
     LIMIT 1) AS MIN_TABLE
CROSS JOIN 
    (SELECT 
        State_uts, 
        MAX(total_cases) AS Maximum_cases
     FROM 
        covid_data
     GROUP BY 
        State_uts
     ORDER BY 
        Maximum_cases DESC
     LIMIT 1) AS MAX_TABLE;

--7. Max Death vs Min Death

Select 
	MIN_TABLE.State_uts AS State_with_Minimum_deaths,
    MIN_TABLE.Minimum_Deaths,
    MAX_TABLE.State_uts AS State_with_Maximum_deaths,
    MAX_TABLE.Maximum_Deaths
From
(Select state_uts, MIN(deaths) as Minimum_Deaths from Covid_data
group by state_uts order by Minimum_Deaths limit 1) as Min_table
CRoss JOIn
(Select state_uts, MAX(deaths) as Maximum_Deaths from Covid_data
group by state_uts order by Maximum_Deaths desc limit 1) as Max_table

--8.Max Active Cases vs Min Active Cases
Select 
	MIN_TABLE.State_uts AS State_with_Minimum_deaths,
    MIN_TABLE.Minimum_Active_cases,
    MAX_TABLE.State_uts AS State_with_Maximum_deaths,
    MAX_TABLE.Maximum_Active_cases
From
(Select state_uts, MIN(Active) as Minimum_Active_cases from Covid_data
group by state_uts order by Minimum_Active_cases limit 1) as Min_table
CRoss JOIn
(Select state_uts, MAX(Active) as Maximum_Active_cases from Covid_data
group by state_uts order by Maximum_Active_cases desc limit 1) as Max_table


--9.
SELECT 
    'South India' AS Region, 
    ROUND(AVG(Death_Ratio), 2) AS Avg_Death_Rate 
FROM 
    Covid_data
WHERE 
    state_uts IN ('Tamil Nadu','Puducherry','Telangana','Andhra Pradesh','Karnataka','Kerala')

UNION ALL

SELECT 
    'North India' AS Region, 
    ROUND(AVG(Death_Ratio), 2) AS Avg_Death_Rate 
FROM 
    Covid_data
WHERE 
    state_uts NOT IN ('Tamil Nadu','Puducherry','Telangana','Andhra Pradesh','Karnataka','Kerala');
