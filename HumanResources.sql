DROP DATABASE IF EXISTS projects;
CREATE DATABASE IF NOT EXISTS projects;

USE projects;
SELECT * FROM hr;
ALTER TABLE hr CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NOT NULL;
DESCRIBE hr;

SELECT birthdate FROM hr;

SET SQL_SAFE_UPDATES = 0;

-- CHANGING THE DATE FORMAT OF THE birthdate COLUMN
UPDATE hr
SET birthdate = CASE 
	WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
    END;

ALTER TABLE hr MODIFY birthdate DATE;

-- CHANGING THE DATE FORMAT OF THE hire_date COLUMN
UPDATE hr
SET hire_date = CASE 
	WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
    END;
    
SELECT termdate FROM hr;


UPDATE hr SET termdate = '0000-00-00' WHERE termdate IS NULL OR termdate = '';

-- SETTING NULL OR EMPTY DATE TO DEFAULT '0001-01-01'
UPDATE hr
SET termdate = '0001-01-01'
WHERE termdate = '0000-00-00';

-- MODIFYING THE termdate to DATATYPE OF DATE
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- CHANGING THE HIRE DATE TO DATE DATATYPE
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- ADDING THE AGE COLUMN
ALTER TABLE hr
ADD COLUMN age INT AFTER birthdate;

-- Adding the age values
UPDATE hr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());

SELECT * FROM hr;

-- REQUIRED EMPLOYEES
SELECT MIN(age) AS Youngest, MAX(age) AS Oldest FROM hr;

-- THE GENDER BREAKDOWN OF EMPLOYEES IN THE COMPANY
SELECT gender, COUNT(*) AS count FROM hr
WHERE age >= 18 AND termdate = '0001-01-01'
GROUP BY gender;

-- RACE /ethnicity breakdown
SELECT race, COUNT(*) AS RaceCount
FROM hr
WHERE age >= 18 and termdate = '0001-01-01'
GROUP BY race
ORDER BY RaceCount DESC;

-- DISTRIBUTION OF EMPLOYEES IN THE COMPANY
SELECT MIN(age) AS Youngest, MAX(age) AS Oldest
FROM hr
WHERE age >= 18 and termdate = '0001-01-01';

-- AGE GROPUS
SELECT
	CASE
		WHEN age >= 18 and age <=24 THEN '18-24'
        WHEN age >= 25 and age <=34 THEN '25-34'
        WHEN age >= 35 and age <=44 THEN '35-44'
        WHEN age >= 45 and age <=54 THEN '45-54'
        WHEN age >= 55 and age <=54 THEN '55-64'
        ELSE '65+'
	END AS AgeGroup,
    COUNT(*) AS AgeCount
    FROM hr
    WHERE age >= 18 AND termdate = '0001-01-01'
    GROUP BY AgeGroup
    ORDER by AgeGroup;
    
-- AGE/GENDER GROPUS
SELECT
	CASE
		WHEN age >= 18 and age <=24 THEN '18-24'
        WHEN age >= 25 and age <=34 THEN '25-34'
        WHEN age >= 35 and age <=44 THEN '35-44'
        WHEN age >= 45 and age <=54 THEN '45-54'
        WHEN age >= 55 and age <=54 THEN '55-64'
        ELSE '65+'
	END AS AgeGroup,gender,
    COUNT(*) AS AgeCount
    FROM hr
    WHERE age >= 18 AND termdate = '0001-01-01'
    GROUP BY AgeGroup, gender
    ORDER by AgeGroup, gender;
    
    
    -- EMPLOYEES WORK AT HEADQUARTERS VERSUS REMOTE LOCATIONS
    SELECT location, COUNT(*) AS LocationCount 
    FROM hr
    WHERE age >= 18 AND termdate = '0001-01-01'
    GROUP BY location;


-- THE AVERAGE LENGTH OF EMPLOYMENT FOR EMPLOYEES WHO HAVE BEEN TERMINATED
SELECT 
ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AverageLengthEmployment
FROM hr
WHERE termdate <= CURDATE() AND termdate <> '0001-01-01' AND age >= 18;

-- GENDER DISTRIBUTION ACCROSS DEPARTMENT AND JOB TITLES
SELECT department, gender, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0001-01-01'
GROUP BY department, gender
ORDER BY department;

-- DISTRIBUTION OF JOB TITLES ACCROSS THE COMPANY
SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE age >= 18 and termdate = '0001-01-01'
GROUP BY jobtitle
ORDER BY jobtitle DESC;


-- Department HAS THE HIGHEST TURNOVER RATE
SELECT department,
total_count,
terminated_count,
terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    COUNT(*) AS total_count,
    SUM(CASE WHEN termdate <> '0001-01-01' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
) AS subquery
ORDER BY termination_rate DESC;



-- DISTRIBUTION OF EMPLOYEES ACCROSS LOCATIONS BY CITY AND STATE
SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0001-01-01'
GROUP BY location_state
ORDER BY count DESC;

-- HOW HAS THE COMPANIES EMPLOYEES COUNT CHANGED OVER TIME ON HIRE AND TERM DATES
SELECT
year,
hires,
terminations,
-- To get the net_change we substract terminations from hires
hires - terminations AS net_change,
ROUND((hires - terminations)/hires*100,2) as net_change_percent
FROM (
	SELECT YEAR(hire_date) as year,
    COUNT(*) as hires,
    SUM(CASE WHEN termdate <> '0001-01-01' AND termdate <= CURDATE()
    THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
    GROUP BY YEAR(hire_date)

) as subquery
ORDER BY year ASC;

-- THE TENURE DISTRIBUTION FOR EACH DEPARTMENt
SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date)/365), 0)
AS avg_tenure
FROM hr
WHERE termdate <= CURDATE() AND termdate <> '0001-01-01' AND age >= 18
GROUP BY department;


    

