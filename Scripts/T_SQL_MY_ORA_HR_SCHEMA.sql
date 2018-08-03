-- ********************************************************************
-- Drops

DROP SEQUENCE IF EXISTS ora_hr.locations_seq;
DROP SEQUENCE IF EXISTS ora_hr.departments_seq;
DROP SEQUENCE IF EXISTS ora_hr.employees_seq;

GO

--Departments has a FK to employees (U = Table (user-defined))
DECLARE @deptTableId INT;
SET @deptTableId = (SELECT OBJECT_ID('ORA_HR.DEPARTMENTS', N'U'));

IF @deptTableId IS NOT NULL
  ALTER TABLE ora_hr.departments
    DROP CONSTRAINT IF EXISTS dept_mgr_fk;
 
GO 

DROP VIEW IF EXISTS ora_hr.emp_details_view;

DROP TABLE IF EXISTS ora_hr.job_history;

--The employees table is temporal (versioned)
IF OBJECT_ID('ORA_HR.EMPLOYEES', N'U') IS NOT NULL
BEGIN
  IF OBJECTPROPERTY(OBJECT_ID('ORA_HR.EMPLOYEES', N'U'), N'TableTemporalType') = 2
    ALTER TABLE ora_hr.employees
      SET (SYSTEM_VERSIONING = OFF);

  DROP TABLE IF EXISTS ora_hr.employeesHistory, ora_hr.employees;

END;

DROP TABLE IF EXISTS ora_hr.jobs;
DROP TABLE IF EXISTS ora_hr.departments;
DROP TABLE IF EXISTS ora_hr.locations;
DROP TABLE IF EXISTS ora_hr.countries;
DROP TABLE IF EXISTS ora_hr.regions;  

DROP SCHEMA IF EXISTS ora_hr;

GO

-- ********************************************************************
-- Schema

CREATE SCHEMA ora_hr;
GO

-- ********************************************************************
-- Create the REGIONS table to hold region information for locations
-- HR.LOCATIONS table has a foreign key to this table.

CREATE TABLE ora_hr.regions
   ( region_id   INT CONSTRAINT region_id_nn NOT NULL 
   , region_name VARCHAR(25) 
   );
   
ALTER TABLE ora_hr.regions ADD CONSTRAINT reg_id_pk PRIMARY KEY (region_id);

-- ********************************************************************
-- Create the COUNTRIES table to hold country information for customers
-- and company locations. 
-- OE.CUSTOMERS table and HR.LOCATIONS have a foreign key to this table.

CREATE TABLE ora_hr.countries 
   ( country_id   VARCHAR(2) CONSTRAINT country_id_nn NOT NULL 
   , country_name VARCHAR(40) 
   , region_id    INT 
   , CONSTRAINT country_c_id_pk PRIMARY KEY (country_id) 
   );
   
ALTER TABLE ora_hr.countries
  ADD CONSTRAINT countr_reg_fk
  FOREIGN KEY (region_id) REFERENCES ora_hr.regions(region_id);
        
        
-- ********************************************************************
-- Create the LOCATIONS table to hold address information for company departments.
-- HR.DEPARTMENTS has a foreign key to this table.
       
DROP TABLE IF EXISTS ora_hr.locations;

CREATE TABLE ora_hr.locations
   ( location_id    INT         CONSTRAINT loc_location_id_nn NOT NULL
   , street_address VARCHAR(40)
   , postal_code    VARCHAR(12)
   , city           VARCHAR(30) CONSTRAINT loc_city_nn NOT NULL
   , state_province VARCHAR(25)
   , country_id     VARCHAR(2)
   ) ;

ALTER TABLE ora_hr.locations ADD 
  CONSTRAINT loc_id_pk PRIMARY KEY (location_id);

ALTER TABLE ora_hr.locations ADD   
  CONSTRAINT loc_c_id_fk
  FOREIGN KEY (country_id) REFERENCES ora_hr.countries(country_id);
   
-- Sequence
CREATE SEQUENCE ora_hr.locations_seq
   START WITH 3300
   INCREMENT BY 100;
   
-- ********************************************************************
-- Create the DEPARTMENTS table to hold company department information.
-- HR.EMPLOYEES and HR.JOB_HISTORY have a foreign key to this table.
       
CREATE TABLE ora_hr.departments
   ( department_id   INT         CONSTRAINT dept_id_nn NOT NULL
   , department_name VARCHAR(30) CONSTRAINT dept_name_nn NOT NULL
   , manager_id      INT
   , location_id     INT
   ) ;

ALTER TABLE ora_hr.departments
  ADD CONSTRAINT dept_id_pk PRIMARY KEY (department_id);
  
ALTER TABLE ora_hr.departments  
  ADD CONSTRAINT dept_loc_fk
   FOREIGN KEY (location_id) REFERENCES ora_hr.locations (location_id);
   
--Sequence
CREATE SEQUENCE ora_hr.departments_seq
   START WITH 280
   INCREMENT BY 10;
   
-- ********************************************************************
-- Create the JOBS table to hold the different names of job roles within the company.
-- HR.EMPLOYEES has a foreign key to this table.
       
CREATE TABLE ora_hr.jobs
   ( job_id     VARCHAR(10) CONSTRAINT job_id_nn NOT NULL
   , job_title  VARCHAR(35) CONSTRAINT job_title_nn NOT NULL
   , min_salary INT
   , max_salary INT
   ) ;

ALTER TABLE ora_hr.jobs ADD CONSTRAINT job_id_pk PRIMARY KEY(job_id);
   
-- ********************************************************************
-- Create the EMPLOYEES table to hold the employee personnel 
-- information for the company.
-- HR.EMPLOYEES has a self referencing foreign key to this table.
--
-- Update - The employees table has been made temporal       
CREATE TABLE ora_hr.employees
   ( employee_id    INT         CONSTRAINT emp_id_nn NOT NULL
   , first_name     VARCHAR(20)
   , last_name      VARCHAR(25) CONSTRAINT emp_last_name_nn NOT NULL
   , email          VARCHAR(25) CONSTRAINT emp_email_nn NOT NULL
   , phone_number   VARCHAR(20)
   , hire_date      DATE        CONSTRAINT emp_hire_date_nn NOT NULL
   , job_id         VARCHAR(10) CONSTRAINT emp_job_nn NOT NULL
   , salary         NUMERIC(8,2)
   , commission_pct NUMERIC(2,2)
   , manager_id     INT
   , department_id  INT
   , sysstart       DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
   , sysend         DATETIME2(0) GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL
   , PERIOD FOR SYSTEM_TIME(sysstart, sysend)
   , CONSTRAINT emp_emp_id_pk PRIMARY KEY (employee_id)
   , CONSTRAINT emp_salary_min CHECK (salary > 0) 
   , CONSTRAINT emp_email_uk UNIQUE (email)
   ) 
   WITH (
     SYSTEM_VERSIONING = ON (HISTORY_TABLE = ora_hr.employeesHistory)
   );         

ALTER TABLE ora_hr.employees  
  ADD CONSTRAINT emp_dept_fk
  FOREIGN KEY (department_id) REFERENCES ora_hr.departments;
   
ALTER TABLE ora_hr.employees   
  ADD CONSTRAINT emp_job_fk
  FOREIGN KEY (job_id) REFERENCES ora_hr.jobs (job_id);

ALTER TABLE ora_hr.employees   
  ADD CONSTRAINT emp_manager_fk
  FOREIGN KEY (manager_id) REFERENCES ora_hr.employees;
    
--Sequence
CREATE SEQUENCE ora_hr.employees_seq
   START WITH 207
   INCREMENT BY 1;
   
-- ********************************************************************
-- Create the JOB_HISTORY table to hold the history of jobs that 
-- employees have held in the past.
-- HR.JOBS, HR_DEPARTMENTS, and HR.EMPLOYEES have a foreign key to this table.
       
CREATE TABLE ora_hr.job_history
   ( employee_id     INT          CONSTRAINT jhist_employee_nn NOT NULL
   , start_date      DATE         CONSTRAINT jhist_start_date_nn NOT NULL
   , end_date        DATE         CONSTRAINT jhist_end_date_nn NOT NULL
   , job_id          VARCHAR(10)  CONSTRAINT jhist_job_nn NOT NULL
   , department_id   INT
   , CONSTRAINT jhist_date_interval CHECK (end_date > start_date)
   ) ;

ALTER TABLE ora_hr.job_history
  ADD CONSTRAINT jhist_emp_id_st_date_pk PRIMARY KEY (employee_id, start_date);
  
ALTER TABLE ora_hr.job_history   
  ADD CONSTRAINT jhist_job_fk
  FOREIGN KEY (job_id) REFERENCES ora_hr.jobs;
  
ALTER TABLE ora_hr.job_history     
  ADD CONSTRAINT jhist_emp_fk
  FOREIGN KEY (employee_id) REFERENCES ora_hr.employees;
   
ALTER TABLE ora_hr.job_history      
  ADD CONSTRAINT jhist_dept_fk
  FOREIGN KEY (department_id) REFERENCES ora_hr.departments;
  
GO
  
-- ********************************************************************
-- Create the EMP_DETAILS_VIEW that joins the employees, jobs, 
-- departments, jobs, countries, and locations table to provide details
-- about employees.
       
CREATE VIEW ora_hr.emp_details_view
   (employee_id,
   job_id,
   manager_id,
   department_id,
   location_id,
   country_id,
   first_name,
   last_name,
   salary,
   commission_pct,
   department_name,
   job_title,
   city,
   state_province,
   country_name,
   region_name)
   AS SELECT
   e.employee_id, 
   e.job_id, 
   e.manager_id, 
   e.department_id,
   d.location_id,
   l.country_id,
   e.first_name,
   e.last_name,
   e.salary,
   e.commission_pct,
   d.department_name,
   j.job_title,
   l.city,
   l.state_province,
   c.country_name,
   r.region_name
   FROM
   employees e
   JOIN departments d
     ON e.department_id = d.department_id
   JOIN jobs j
     ON j.job_id = e.job_id
   JOIN locations l
     ON d.location_id = l.location_id
   JOIN countries c
     ON l.country_id = c.country_id
   JOIN regions r
     ON c.region_id = r.region_id;

GO
     
--
-- Data
--  
BEGIN TRANSACTION

-- ***************************insert data into the REGIONS table
INSERT INTO ora_hr.regions VALUES 
   ( 1
   , 'Europe' 
   );
INSERT INTO ora_hr.regions VALUES 
   ( 2
   , 'Americas' 
   );
INSERT INTO ora_hr.regions VALUES 
   ( 3
   , 'Asia' 
   );
INSERT INTO ora_hr.regions VALUES 
   ( 4
   , 'Middle East and Africa' 
   );
   
-- ***************************insert data into the COUNTRIES table
INSERT INTO ora_hr.countries VALUES 
   ( 'IT'
   , 'Italy'
   , 1 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'JP'
   , 'Japan'
   , 3 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'US'
   , 'United States of America'
   , 2 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'CA'
   , 'Canada'
   , 2 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'CN'
   , 'China'
   , 3 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'IN'
   , 'India'
   , 3 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'AU'
   , 'Australia'
   , 3 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'ZW'
   , 'Zimbabwe'
   , 4 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'SG'
   , 'Singapore'
   , 3 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'UK'
   , 'United Kingdom'
   , 1 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'FR'
   , 'France'
   , 1 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'DE'
   , 'Germany'
   , 1 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'ZM'
   , 'Zambia'
   , 4 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'EG'
   , 'Egypt'
   , 4 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'BR'
   , 'Brazil'
   , 2 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'CH'
   , 'Switzerland'
   , 1 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'NL'
   , 'Netherlands'
   , 1 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'MX'
   , 'Mexico'
   , 2 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'KW'
   , 'Kuwait'
   , 4 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'IL'
   , 'Israel'
   , 4 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'DK'
   , 'Denmark'
   , 1 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'HK'
   , 'HongKong'
   , 3 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'NG'
   , 'Nigeria'
   , 4 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'AR'
   , 'Argentina'
   , 2 
   );
INSERT INTO ora_hr.countries VALUES 
   ( 'BE'
   , 'Belgium'
   , 1 
   );
       
-- ***************************insert data into the LOCATIONS table       
INSERT INTO ora_hr.locations VALUES 
   ( 1000 
   , '1297 Via Cola di Rie'
   , '00989'
   , 'Roma'
   , NULL
   , 'IT'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1100 
   , '93091 Calle della Testa'
   , '10934'
   , 'Venice'
   , NULL
   , 'IT'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1200 
   , '2017 Shinjuku-ku'
   , '1689'
   , 'Tokyo'
   , 'Tokyo Prefecture'
   , 'JP'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1300 
   , '9450 Kamiya-cho'
   , '6823'
   , 'Hiroshima'
   , NULL
   , 'JP'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1400 
   , '2014 Jabberwocky Rd'
   , '26192'
   , 'Southlake'
   , 'Texas'
   , 'US'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1500 
   , '2011 Interiors Blvd'
   , '99236'
   , 'South San Francisco'
   , 'California'
   , 'US'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1600 
   , '2007 Zagora St'
   , '50090'
   , 'South Brunswick'
   , 'New Jersey'
   , 'US'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1700 
   , '2004 Charade Rd'
   , '98199'
   , 'Seattle'
   , 'Washington'
   , 'US'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1800 
   , '147 Spadina Ave'
   , 'M5V 2L7'
   , 'Toronto'
   , 'Ontario'
   , 'CA'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 1900 
   , '6092 Boxwood St'
   , 'YSW 9T2'
   , 'Whitehorse'
   , 'Yukon'
   , 'CA'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2000 
   , '40-5-12 Laogianggen'
   , '190518'
   , 'Beijing'
   , NULL
   , 'CN'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2100 
   , '1298 Vileparle (E)'
   , '490231'
   , 'Bombay'
   , 'Maharashtra'
   , 'IN'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2200 
   , '12-98 Victoria Street'
   , '2901'
   , 'Sydney'
   , 'New South Wales'
   , 'AU'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2300 
   , '198 Clementi North'
   , '540198'
   , 'Singapore'
   , NULL
   , 'SG'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2400 
   , '8204 Arthur St'
   , NULL
   , 'London'
   , NULL
   , 'UK'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2500 
   , 'Magdalen Centre, The Oxford Science Park'
   , 'OX9 9ZB'
   , 'Oxford'
   , 'Oxford'
   , 'UK'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2600 
   , '9702 Chester Road'
   , '09629850293'
   , 'Stretford'
   , 'Manchester'
   , 'UK'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2700 
   , 'Schwanthalerstr. 7031'
   , '80925'
   , 'Munich'
   , 'Bavaria'
   , 'DE'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2800 
   , 'Rua Frei Caneca 1360 '
   , '01307-002'
   , 'Sao Paulo'
   , 'Sao Paulo'
   , 'BR'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 2900 
   , '20 Rue des Corps-Saints'
   , '1730'
   , 'Geneva'
   , 'Geneve'
   , 'CH'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 3000 
   , 'Murtenstrasse 921'
   , '3095'
   , 'Bern'
   , 'BE'
   , 'CH'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 3100 
   , 'Pieter Breughelstraat 837'
   , '3029SK'
   , 'Utrecht'
   , 'Utrecht'
   , 'NL'
   );
INSERT INTO ora_hr.locations VALUES 
   ( 3200 
   , 'Mariano Escobedo 9991'
   , '11932'
   , 'Mexico City'
   , 'Distrito Federal,'
   , 'MX'
   );
       
-- ****************************insert data into the DEPARTMENTS table

INSERT INTO ora_hr.departments VALUES 
   ( 10
   , 'Administration'
   , 200
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 20
   , 'Marketing'
   , 201
   , 1800
   );
   
   INSERT INTO ora_hr.departments VALUES 
   ( 30
   , 'Purchasing'
   , 114
   , 1700
   );
   
   INSERT INTO ora_hr.departments VALUES 
   ( 40
   , 'Human Resources'
   , 203
   , 2400
   );
INSERT INTO ora_hr.departments VALUES 
   ( 50
   , 'Shipping'
   , 121
   , 1500
   );
   
   INSERT INTO ora_hr.departments VALUES 
   ( 60 
   , 'IT'
   , 103
   , 1400
   );
   
   INSERT INTO ora_hr.departments VALUES 
   ( 70 
   , 'Public Relations'
   , 204
   , 2700
   );
   
   INSERT INTO ora_hr.departments VALUES 
   ( 80 
   , 'Sales'
   , 145
   , 2500
   );
   
   INSERT INTO ora_hr.departments VALUES 
   ( 90 
   , 'Executive'
   , 100
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 100 
   , 'Finance'
   , 108
   , 1700
   );
   
   INSERT INTO ora_hr.departments VALUES 
   ( 110 
   , 'Accounting'
   , 205
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 120 
   , 'Treasury'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 130 
   , 'Corporate Tax'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 140 
   , 'Control And Credit'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 150 
   , 'Shareholder Services'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 160 
   , 'Benefits'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 170 
   , 'Manufacturing'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 180 
   , 'Construction'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 190 
   , 'Contracting'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 200 
   , 'Operations'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 210 
   , 'IT Support'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 220 
   , 'NOC'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 230 
   , 'IT Helpdesk'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 240 
   , 'Government Sales'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 250 
   , 'Retail Sales'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 260 
   , 'Recruiting'
   , NULL
   , 1700
   );
INSERT INTO ora_hr.departments VALUES 
   ( 270 
   , 'Payroll'
   , NULL
   , 1700
   );
       
-- ***************************insert data into the JOBS table
INSERT INTO ora_hr.jobs VALUES 
   ( 'AD_PRES'
   , 'President'
   , 20000
   , 40000
   );
   INSERT INTO ora_hr.jobs VALUES 
   ( 'AD_VP'
   , 'Administration Vice President'
   , 15000
   , 30000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'AD_ASST'
   , 'Administration Assistant'
   , 3000
   , 6000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'FI_MGR'
   , 'Finance Manager'
   , 8200
   , 16000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'FI_ACCOUNT'
   , 'Accountant'
   , 4200
   , 9000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'AC_MGR'
   , 'Accounting Manager'
   , 8200
   , 16000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'AC_ACCOUNT'
   , 'Public Accountant'
   , 4200
   , 9000
   );
   INSERT INTO ora_hr.jobs VALUES 
   ( 'SA_MAN'
   , 'Sales Manager'
   , 10000
   , 20000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'SA_REP'
   , 'Sales Representative'
   , 6000
   , 12000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'PU_MAN'
   , 'Purchasing Manager'
   , 8000
   , 15000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'PU_CLERK'
   , 'Purchasing Clerk'
   , 2500
   , 5500
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'ST_MAN'
   , 'Stock Manager'
   , 5500
   , 8500
   );
   INSERT INTO ora_hr.jobs VALUES 
   ( 'ST_CLERK'
   , 'Stock Clerk'
   , 2000
   , 5000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'SH_CLERK'
   , 'Shipping Clerk'
   , 2500
   , 5500
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'IT_PROG'
   , 'Programmer'
   , 4000
   , 10000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'MK_MAN'
   , 'Marketing Manager'
   , 9000
   , 15000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'MK_REP'
   , 'Marketing Representative'
   , 4000
   , 9000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'HR_REP'
   , 'Human Resources Representative'
   , 4000
   , 9000
   );
INSERT INTO ora_hr.jobs VALUES 
   ( 'PR_REP'
   , 'Public Relations Representative'
   , 4500
   , 10500
   );
       
-- ***************************insert data into the EMPLOYEES table
-- Replaced the TO_DATE function calls with DATEFROMPARTS 
-- ([0-9]+),([0-9]+),([0-9]+) with \3,\2,\1
-- then forgot the quotes!!! 
-- so then '([0-9]+),([0-9]+),([0-9]+)' with \1, \2, \3

INSERT INTO ora_hr.employees VALUES 
   ( 100
   , 'Steven'
   , 'King'
   , 'SKING'
   , '515.123.4567'
   , DATEFROMPARTS(1987,6,17)
   , 'AD_PRES'
   , 24000
   , NULL
   , NULL
   , 90
   );
INSERT INTO ora_hr.employees VALUES 
   ( 101
   , 'Neena'
   , 'Kochhar'
   , 'NKOCHHAR'
   , '515.123.4568'
   , DATEFROMPARTS(1989,9,21)
   , 'AD_VP'
   , 17000
   , NULL
   , 100
   , 90
   );
INSERT INTO ora_hr.employees VALUES 
   ( 102
   , 'Lex'
   , 'De Haan'
   , 'LDEHAAN'
   , '515.123.4569'
   , DATEFROMPARTS(1993,1,13)
   , 'AD_VP'
   , 17000
   , NULL
   , 100
   , 90
   );
INSERT INTO ora_hr.employees VALUES 
   ( 103
   , 'Alexander'
   , 'Hunold'
   , 'AHUNOLD'
   , '590.423.4567'
   , DATEFROMPARTS(1990,1,03)
   , 'IT_PROG'
   , 9000
   , NULL
   , 102
   , 60
   );
INSERT INTO ora_hr.employees VALUES 
   ( 104
   , 'Bruce'
   , 'Ernst'
   , 'BERNST'
   , '590.423.4568'
   , DATEFROMPARTS(1991,5,21)
   , 'IT_PROG'
   , 6000
   , NULL
   , 103
   , 60
   );
INSERT INTO ora_hr.employees VALUES 
   ( 105
   , 'David'
   , 'Austin'
   , 'DAUSTIN'
   , '590.423.4569'
   , DATEFROMPARTS(1997,6,25)
   , 'IT_PROG'
   , 4800
   , NULL
   , 103
   , 60
   );
INSERT INTO ora_hr.employees VALUES 
   ( 106
   , 'Valli'
   , 'Pataballa'
   , 'VPATABAL'
   , '590.423.4560'
   , DATEFROMPARTS(1998,2,05)
   , 'IT_PROG'
   , 4800
   , NULL
   , 103
   , 60
   );
INSERT INTO ora_hr.employees VALUES 
   ( 107
   , 'Diana'
   , 'Lorentz'
   , 'DLORENTZ'
   , '590.423.5567'
   , DATEFROMPARTS(1999,2,07)
   , 'IT_PROG'
   , 4200
   , NULL
   , 103
   , 60
   );
INSERT INTO ora_hr.employees VALUES 
   ( 108
   , 'Nancy'
   , 'Greenberg'
   , 'NGREENBE'
   , '515.124.4569'
   , DATEFROMPARTS(1994,8,17)
   , 'FI_MGR'
   , 12000
   , NULL
   , 101
   , 100
   );
INSERT INTO ora_hr.employees VALUES 
   ( 109
   , 'Daniel'
   , 'Faviet'
   , 'DFAVIET'
   , '515.124.4169'
   , DATEFROMPARTS(1994,8,16)
   , 'FI_ACCOUNT'
   , 9000
   , NULL
   , 108
   , 100
   );
INSERT INTO ora_hr.employees VALUES 
   ( 110
   , 'John'
   , 'Chen'
   , 'JCHEN'
   , '515.124.4269'
   , DATEFROMPARTS(1997,9,28)
   , 'FI_ACCOUNT'
   , 8200
   , NULL
   , 108
   , 100
   );
INSERT INTO ora_hr.employees VALUES 
   ( 111
   , 'Ismael'
   , 'Sciarra'
   , 'ISCIARRA'
   , '515.124.4369'
   , DATEFROMPARTS(1997,9,30)
   , 'FI_ACCOUNT'
   , 7700
   , NULL
   , 108
   , 100
   );
INSERT INTO ora_hr.employees VALUES 
   ( 112
   , 'Jose Manuel'
   , 'Urman'
   , 'JMURMAN'
   , '515.124.4469'
   , DATEFROMPARTS(1998,3,07)
   , 'FI_ACCOUNT'
   , 7800
   , NULL
   , 108
   , 100
   );
INSERT INTO ora_hr.employees VALUES 
   ( 113
   , 'Luis'
   , 'Popp'
   , 'LPOPP'
   , '515.124.4567'
   , DATEFROMPARTS(1999,12,07)
   , 'FI_ACCOUNT'
   , 6900
   , NULL
   , 108
   , 100
   );
INSERT INTO ora_hr.employees VALUES 
   ( 114
   , 'Den'
   , 'Raphaely'
   , 'DRAPHEAL'
   , '515.127.4561'
   , DATEFROMPARTS(1994,12,07)
   , 'PU_MAN'
   , 11000
   , NULL
   , 100
   , 30
   );
INSERT INTO ora_hr.employees VALUES 
   ( 115
   , 'Alexander'
   , 'Khoo'
   , 'AKHOO'
   , '515.127.4562'
   , DATEFROMPARTS(1995,5,18)
   , 'PU_CLERK'
   , 3100
   , NULL
   , 114
   , 30
   );
INSERT INTO ora_hr.employees VALUES 
   ( 116
   , 'Shelli'
   , 'Baida'
   , 'SBAIDA'
   , '515.127.4563'
   , DATEFROMPARTS(1997,12,24)
   , 'PU_CLERK'
   , 2900
   , NULL
   , 114
   , 30
   );
INSERT INTO ora_hr.employees VALUES 
   ( 117
   , 'Sigal'
   , 'Tobias'
   , 'STOBIAS'
   , '515.127.4564'
   , DATEFROMPARTS(1997,7,24)
   , 'PU_CLERK'
   , 2800
   , NULL
   , 114
   , 30
   );
INSERT INTO ora_hr.employees VALUES 
   ( 118
   , 'Guy'
   , 'Himuro'
   , 'GHIMURO'
   , '515.127.4565'
   , DATEFROMPARTS(1998,11,15)
   , 'PU_CLERK'
   , 2600
   , NULL
   , 114
   , 30
   );
INSERT INTO ora_hr.employees VALUES 
   ( 119
   , 'Karen'
   , 'Colmenares'
   , 'KCOLMENA'
   , '515.127.4566'
   , DATEFROMPARTS(1999,8,10)
   , 'PU_CLERK'
   , 2500
   , NULL
   , 114
   , 30
   );
INSERT INTO ora_hr.employees VALUES 
   ( 120
   , 'Matthew'
   , 'Weiss'
   , 'MWEISS'
   , '650.123.1234'
   , DATEFROMPARTS(1996,7,18)
   , 'ST_MAN'
   , 8000
   , NULL
   , 100
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 121
   , 'Adam'
   , 'Fripp'
   , 'AFRIPP'
   , '650.123.2234'
   , DATEFROMPARTS(1997,4,10)
   , 'ST_MAN'
   , 8200
   , NULL
   , 100
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 122
   , 'Payam'
   , 'Kaufling'
   , 'PKAUFLIN'
   , '650.123.3234'
   , DATEFROMPARTS(1995,5,01)
   , 'ST_MAN'
   , 7900
   , NULL
   , 100
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 123
   , 'Shanta'
   , 'Vollman'
   , 'SVOLLMAN'
   , '650.123.4234'
   , DATEFROMPARTS(1997,10,10)
   , 'ST_MAN'
   , 6500
   , NULL
   , 100
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 124
   , 'Kevin'
   , 'Mourgos'
   , 'KMOURGOS'
   , '650.123.5234'
   , DATEFROMPARTS(1999,11,16)
   , 'ST_MAN'
   , 5800
   , NULL
   , 100
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 125
   , 'Julia'
   , 'Nayer'
   , 'JNAYER'
   , '650.124.1214'
   , DATEFROMPARTS(1997,7,16)
   , 'ST_CLERK'
   , 3200
   , NULL
   , 120
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 126
   , 'Irene'
   , 'Mikkilineni'
   , 'IMIKKILI'
   , '650.124.1224'
   , DATEFROMPARTS(1998,9,28)
   , 'ST_CLERK'
   , 2700
   , NULL
   , 120
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 127
   , 'James'
   , 'Landry'
   , 'JLANDRY'
   , '650.124.1334'
   , DATEFROMPARTS(1999,1,14)
   , 'ST_CLERK'
   , 2400
   , NULL
   , 120
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 128
   , 'Steven'
   , 'Markle'
   , 'SMARKLE'
   , '650.124.1434'
   , DATEFROMPARTS(2000,3,08)
   , 'ST_CLERK'
   , 2200
   , NULL
   , 120
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 129
   , 'Laura'
   , 'Bissot'
   , 'LBISSOT'
   , '650.124.5234'
   , DATEFROMPARTS(1997,8,20)
   , 'ST_CLERK'
   , 3300
   , NULL
   , 121
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 130
   , 'Mozhe'
   , 'Atkinson'
   , 'MATKINSO'
   , '650.124.6234'
   , DATEFROMPARTS(1997,10,30)
   , 'ST_CLERK'
   , 2800
   , NULL
   , 121
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 131
   , 'James'
   , 'Marlow'
   , 'JAMRLOW'
   , '650.124.7234'
   , DATEFROMPARTS(1997,2,16)
   , 'ST_CLERK'
   , 2500
   , NULL
   , 121
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 132
   , 'TJ'
   , 'Olson'
   , 'TJOLSON'
   , '650.124.8234'
   , DATEFROMPARTS(1999,4,10)
   , 'ST_CLERK'
   , 2100
   , NULL
   , 121
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 133
   , 'Jason'
   , 'Mallin'
   , 'JMALLIN'
   , '650.127.1934'
   , DATEFROMPARTS(1996,6,14)
   , 'ST_CLERK'
   , 3300
   , NULL
   , 122
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 134
   , 'Michael'
   , 'Rogers'
   , 'MROGERS'
   , '650.127.1834'
   , DATEFROMPARTS(1998,8,26)
   , 'ST_CLERK'
   , 2900
   , NULL
   , 122
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 135
   , 'Ki'
   , 'Gee'
   , 'KGEE'
   , '650.127.1734'
   , DATEFROMPARTS(1999,12,12)
   , 'ST_CLERK'
   , 2400
   , NULL
   , 122
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 136
   , 'Hazel'
   , 'Philtanker'
   , 'HPHILTAN'
   , '650.127.1634'
   , DATEFROMPARTS(2000,2,06)
   , 'ST_CLERK'
   , 2200
   , NULL
   , 122
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 137
   , 'Renske'
   , 'Ladwig'
   , 'RLADWIG'
   , '650.121.1234'
   , DATEFROMPARTS(1995,7,14)
   , 'ST_CLERK'
   , 3600
   , NULL
   , 123
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 138
   , 'Stephen'
   , 'Stiles'
   , 'SSTILES'
   , '650.121.2034'
   , DATEFROMPARTS(1997,10,26)
   , 'ST_CLERK'
   , 3200
   , NULL
   , 123
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 139
   , 'John'
   , 'Seo'
   , 'JSEO'
   , '650.121.2019'
   , DATEFROMPARTS(1998,2,12)
   , 'ST_CLERK'
   , 2700
   , NULL
   , 123
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 140
   , 'Joshua'
   , 'Patel'
   , 'JPATEL'
   , '650.121.1834'
   , DATEFROMPARTS(1998,4,06)
   , 'ST_CLERK'
   , 2500
   , NULL
   , 123
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 141
   , 'Trenna'
   , 'Rajs'
   , 'TRAJS'
   , '650.121.8009'
   , DATEFROMPARTS(1995,10,17)
   , 'ST_CLERK'
   , 3500
   , NULL
   , 124
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 142
   , 'Curtis'
   , 'Davies'
   , 'CDAVIES'
   , '650.121.2994'
   , DATEFROMPARTS(1997,1,29)
   , 'ST_CLERK'
   , 3100
   , NULL
   , 124
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 143
   , 'Randall'
   , 'Matos'
   , 'RMATOS'
   , '650.121.2874'
   , DATEFROMPARTS(1998,3,15)
   , 'ST_CLERK'
   , 2600
   , NULL
   , 124
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 144
   , 'Peter'
   , 'Vargas'
   , 'PVARGAS'
   , '650.121.2004'
   , DATEFROMPARTS(1998,7,09)
   , 'ST_CLERK'
   , 2500
   , NULL
   , 124
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 145
   , 'John'
   , 'Russell'
   , 'JRUSSEL'
   , '011.44.1344.429268'
   , DATEFROMPARTS(1996,10,01)
   , 'SA_MAN'
   , 14000
   , .4
   , 100
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 146
   , 'Karen'
   , 'Partners'
   , 'KPARTNER'
   , '011.44.1344.467268'
   , DATEFROMPARTS(1997,1,05)
   , 'SA_MAN'
   , 13500
   , .3
   , 100
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 147
   , 'Alberto'
   , 'Errazuriz'
   , 'AERRAZUR'
   , '011.44.1344.429278'
   , DATEFROMPARTS(1997,3,10)
   , 'SA_MAN'
   , 12000
   , .3
   , 100
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 148
   , 'Gerald'
   , 'Cambrault'
   , 'GCAMBRAU'
   , '011.44.1344.619268'
   , DATEFROMPARTS(1999,10,15)
   , 'SA_MAN'
   , 11000
   , .3
   , 100
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 149
   , 'Eleni'
   , 'Zlotkey'
   , 'EZLOTKEY'
   , '011.44.1344.429018'
   , DATEFROMPARTS(2000,1,29)
   , 'SA_MAN'
   , 10500
   , .2
   , 100
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 150
   , 'Peter'
   , 'Tucker'
   , 'PTUCKER'
   , '011.44.1344.129268'
   , DATEFROMPARTS(1997,1,30)
   , 'SA_REP'
   , 10000
   , .3
   , 145
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 151
   , 'David'
   , 'Bernstein'
   , 'DBERNSTE'
   , '011.44.1344.345268'
   , DATEFROMPARTS(1997,3,24)
   , 'SA_REP'
   , 9500
   , .25
   , 145
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 152
   , 'Peter'
   , 'Hall'
   , 'PHALL'
   , '011.44.1344.478968'
   , DATEFROMPARTS(1997,8,20)
   , 'SA_REP'
   , 9000
   , .25
   , 145
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 153
   , 'Christopher'
   , 'Olsen'
   , 'COLSEN'
   , '011.44.1344.498718'
   , DATEFROMPARTS(1998,3,30)
   , 'SA_REP'
   , 8000
   , .2
   , 145
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 154
   , 'Nanette'
   , 'Cambrault'
   , 'NCAMBRAU'
   , '011.44.1344.987668'
   , DATEFROMPARTS(1998,12,09)
   , 'SA_REP'
   , 7500
   , .2
   , 145
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 155
   , 'Oliver'
   , 'Tuvault'
   , 'OTUVAULT'
   , '011.44.1344.486508'
   , DATEFROMPARTS(1999,11,23)
   , 'SA_REP'
   , 7000
   , .15
   , 145
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 156
   , 'Janette'
   , 'King'
   , 'JKING'
   , '011.44.1345.429268'
   , DATEFROMPARTS(1996,1,30)
   , 'SA_REP'
   , 10000
   , .35
   , 146
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 157
   , 'Patrick'
   , 'Sully'
   , 'PSULLY'
   , '011.44.1345.929268'
   , DATEFROMPARTS(1996,3,04)
   , 'SA_REP'
   , 9500
   , .35
   , 146
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 158
   , 'Allan'
   , 'McEwen'
   , 'AMCEWEN'
   , '011.44.1345.829268'
   , DATEFROMPARTS(1996,8,01)
   , 'SA_REP'
   , 9000
   , .35
   , 146
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 159
   , 'Lindsey'
   , 'Smith'
   , 'LSMITH'
   , '011.44.1345.729268'
   , DATEFROMPARTS(1997,3,10)
   , 'SA_REP'
   , 8000
   , .3
   , 146
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 160
   , 'Louise'
   , 'Doran'
   , 'LDORAN'
   , '011.44.1345.629268'
   , DATEFROMPARTS(1997,12,15)
   , 'SA_REP'
   , 7500
   , .3
   , 146
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 161
   , 'Sarath'
   , 'Sewall'
   , 'SSEWALL'
   , '011.44.1345.529268'
   , DATEFROMPARTS(1998,11,03)
   , 'SA_REP'
   , 7000
   , .25
   , 146
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 162
   , 'Clara'
   , 'Vishney'
   , 'CVISHNEY'
   , '011.44.1346.129268'
   , DATEFROMPARTS(1997,11,11)
   , 'SA_REP'
   , 10500
   , .25
   , 147
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 163
   , 'Danielle'
   , 'Greene'
   , 'DGREENE'
   , '011.44.1346.229268'
   , DATEFROMPARTS(1999,3,19)
   , 'SA_REP'
   , 9500
   , .15
   , 147
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 164
   , 'Mattea'
   , 'Marvins'
   , 'MMARVINS'
   , '011.44.1346.329268'
   , DATEFROMPARTS(2000,1,24)
   , 'SA_REP'
   , 7200
   , .10
   , 147
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 165
   , 'David'
   , 'Lee'
   , 'DLEE'
   , '011.44.1346.529268'
   , DATEFROMPARTS(2000,2,23)
   , 'SA_REP'
   , 6800
   , .1
   , 147
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 166
   , 'Sundar'
   , 'Ande'
   , 'SANDE'
   , '011.44.1346.629268'
   , DATEFROMPARTS(2000,3,24)
   , 'SA_REP'
   , 6400
   , .10
   , 147
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 167
   , 'Amit'
   , 'Banda'
   , 'ABANDA'
   , '011.44.1346.729268'
   , DATEFROMPARTS(2000,4,21)
   , 'SA_REP'
   , 6200
   , .10
   , 147
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 168
   , 'Lisa'
   , 'Ozer'
   , 'LOZER'
   , '011.44.1343.929268'
   , DATEFROMPARTS(1997,3,11)
   , 'SA_REP'
   , 11500
   , .25
   , 148
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 169 
   , 'Harrison'
   , 'Bloom'
   , 'HBLOOM'
   , '011.44.1343.829268'
   , DATEFROMPARTS(1998,3,23)
   , 'SA_REP'
   , 10000
   , .20
   , 148
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 170
   , 'Tayler'
   , 'Fox'
   , 'TFOX'
   , '011.44.1343.729268'
   , DATEFROMPARTS(1998,1,24)
   , 'SA_REP'
   , 9600
   , .20
   , 148
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 171
   , 'William'
   , 'Smith'
   , 'WSMITH'
   , '011.44.1343.629268'
   , DATEFROMPARTS(1999,2,23)
   , 'SA_REP'
   , 7400
   , .15
   , 148
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 172
   , 'Elizabeth'
   , 'Bates'
   , 'EBATES'
   , '011.44.1343.529268'
   , DATEFROMPARTS(1999,3,24)
   , 'SA_REP'
   , 7300
   , .15
   , 148
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 173
   , 'Sundita'
   , 'Kumar'
   , 'SKUMAR'
   , '011.44.1343.329268'
   , DATEFROMPARTS(2000,4,21)
   , 'SA_REP'
   , 6100
   , .10
   , 148
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 174
   , 'Ellen'
   , 'Abel'
   , 'EABEL'
   , '011.44.1644.429267'
   , DATEFROMPARTS(1996,5,11)
   , 'SA_REP'
   , 11000
   , .30
   , 149
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 175
   , 'Alyssa'
   , 'Hutton'
   , 'AHUTTON'
   , '011.44.1644.429266'
   , DATEFROMPARTS(1997,3,19)
   , 'SA_REP'
   , 8800
   , .25
   , 149
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 176
   , 'Jonathon'
   , 'Taylor'
   , 'JTAYLOR'
   , '011.44.1644.429265'
   , DATEFROMPARTS(1998,3,24)
   , 'SA_REP'
   , 8600
   , .20
   , 149
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 177
   , 'Jack'
   , 'Livingston'
   , 'JLIVINGS'
   , '011.44.1644.429264'
   , DATEFROMPARTS(1998,4,23)
   , 'SA_REP'
   , 8400
   , .20
   , 149
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 178
   , 'Kimberely'
   , 'Grant'
   , 'KGRANT'
   , '011.44.1644.429263'
   , DATEFROMPARTS(1999,5,24)
   , 'SA_REP'
   , 7000
   , .15
   , 149
   , NULL
   );
INSERT INTO ora_hr.employees VALUES 
   ( 179
   , 'Charles'
   , 'Johnson'
   , 'CJOHNSON'
   , '011.44.1644.429262'
   , DATEFROMPARTS(2000,1,04)
   , 'SA_REP'
   , 6200
   , .10
   , 149
   , 80
   );
INSERT INTO ora_hr.employees VALUES 
   ( 180
   , 'Winston'
   , 'Taylor'
   , 'WTAYLOR'
   , '650.507.9876'
   , DATEFROMPARTS(1998,1,24)
   , 'SH_CLERK'
   , 3200
   , NULL
   , 120
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 181
   , 'Jean'
   , 'Fleaur'
   , 'JFLEAUR'
   , '650.507.9877'
   , DATEFROMPARTS(1998,2,23)
   , 'SH_CLERK'
   , 3100
   , NULL
   , 120
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 182
   , 'Martha'
   , 'Sullivan'
   , 'MSULLIVA'
   , '650.507.9878'
   , DATEFROMPARTS(1999,6,21)
   , 'SH_CLERK'
   , 2500
   , NULL
   , 120
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 183
   , 'Girard'
   , 'Geoni'
   , 'GGEONI'
   , '650.507.9879'
   , DATEFROMPARTS(2000,2,03)
   , 'SH_CLERK'
   , 2800
   , NULL
   , 120
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 184
   , 'Nandita'
   , 'Sarchand'
   , 'NSARCHAN'
   , '650.509.1876'
   , DATEFROMPARTS(1996,1,27)
   , 'SH_CLERK'
   , 4200
   , NULL
   , 121
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 185
   , 'Alexis'
   , 'Bull'
   , 'ABULL'
   , '650.509.2876'
   , DATEFROMPARTS(1997,2,20)
   , 'SH_CLERK'
   , 4100
   , NULL
   , 121
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 186
   , 'Julia'
   , 'Dellinger'
   , 'JDELLING'
   , '650.509.3876'
   , DATEFROMPARTS(1998,6,24)
   , 'SH_CLERK'
   , 3400
   , NULL
   , 121
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 187
   , 'Anthony'
   , 'Cabrio'
   , 'ACABRIO'
   , '650.509.4876'
   , DATEFROMPARTS(1999,2,07)
   , 'SH_CLERK'
   , 3000
   , NULL
   , 121
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 188
   , 'Kelly'
   , 'Chung'
   , 'KCHUNG'
   , '650.505.1876'
   , DATEFROMPARTS(1997,6,14)
   , 'SH_CLERK'
   , 3800
   , NULL
   , 122
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 189
   , 'Jennifer'
   , 'Dilly'
   , 'JDILLY'
   , '650.505.2876'
   , DATEFROMPARTS(1997,8,13)
   , 'SH_CLERK'
   , 3600
   , NULL
   , 122
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 190
   , 'Timothy'
   , 'Gates'
   , 'TGATES'
   , '650.505.3876'
   , DATEFROMPARTS(1998,7,11)
   , 'SH_CLERK'
   , 2900
   , NULL
   , 122
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 191
   , 'Randall'
   , 'Perkins'
   , 'RPERKINS'
   , '650.505.4876'
   , DATEFROMPARTS(1999,12,19)
   , 'SH_CLERK'
   , 2500
   , NULL
   , 122
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 192
   , 'Sarah'
   , 'Bell'
   , 'SBELL'
   , '650.501.1876'
   , DATEFROMPARTS(1996,2,04)
   , 'SH_CLERK'
   , 4000
   , NULL
   , 123
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 193
   , 'Britney'
   , 'Everett'
   , 'BEVERETT'
   , '650.501.2876'
   , DATEFROMPARTS(1997,3,03)
   , 'SH_CLERK'
   , 3900
   , NULL
   , 123
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 194
   , 'Samuel'
   , 'McCain'
   , 'SMCCAIN'
   , '650.501.3876'
   , DATEFROMPARTS(1998,7,01)
   , 'SH_CLERK'
   , 3200
   , NULL
   , 123
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 195
   , 'Vance'
   , 'Jones'
   , 'VJONES'
   , '650.501.4876'
   , DATEFROMPARTS(1999,3,17)
   , 'SH_CLERK'
   , 2800
   , NULL
   , 123
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 196
   , 'Alana'
   , 'Walsh'
   , 'AWALSH'
   , '650.507.9811'
   , DATEFROMPARTS(1998,4,24)
   , 'SH_CLERK'
   , 3100
   , NULL
   , 124
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 197
   , 'Kevin'
   , 'Feeney'
   , 'KFEENEY'
   , '650.507.9822'
   , DATEFROMPARTS(1998,5,23)
   , 'SH_CLERK'
   , 3000
   , NULL
   , 124
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 198
   , 'Donald'
   , 'OConnell'
   , 'DOCONNEL'
   , '650.507.9833'
   , DATEFROMPARTS(1999,6,21)
   , 'SH_CLERK'
   , 2600
   , NULL
   , 124
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 199
   , 'Douglas'
   , 'Grant'
   , 'DGRANT'
   , '650.507.9844'
   , DATEFROMPARTS(2000,1,13)
   , 'SH_CLERK'
   , 2600
   , NULL
   , 124
   , 50
   );
INSERT INTO ora_hr.employees VALUES 
   ( 200
   , 'Jennifer'
   , 'Whalen'
   , 'JWHALEN'
   , '515.123.4444'
   , DATEFROMPARTS(1987,9,17)
   , 'AD_ASST'
   , 4400
   , NULL
   , 101
   , 10
   );
INSERT INTO ora_hr.employees VALUES 
   ( 201
   , 'Michael'
   , 'Hartstein'
   , 'MHARTSTE'
   , '515.123.5555'
   , DATEFROMPARTS(1996,2,17)
   , 'MK_MAN'
   , 13000
   , NULL
   , 100
   , 20
   );
INSERT INTO ora_hr.employees VALUES 
   ( 202
   , 'Pat'
   , 'Fay'
   , 'PFAY'
   , '603.123.6666'
   , DATEFROMPARTS(1997,8,17)
   , 'MK_REP'
   , 6000
   , NULL
   , 201
   , 20
   );
INSERT INTO ora_hr.employees VALUES 
   ( 203
   , 'Susan'
   , 'Mavris'
   , 'SMAVRIS'
   , '515.123.7777'
   , DATEFROMPARTS(1994,6,07)
   , 'HR_REP'
   , 6500
   , NULL
   , 101
   , 40
   );
INSERT INTO ora_hr.employees VALUES 
   ( 204
   , 'Hermann'
   , 'Baer'
   , 'HBAER'
   , '515.123.8888'
   , DATEFROMPARTS(1994,6,07)
   , 'PR_REP'
   , 10000
   , NULL
   , 101
   , 70
   );
INSERT INTO ora_hr.employees VALUES 
   ( 205
   , 'Shelley'
   , 'Higgins'
   , 'SHIGGINS'
   , '515.123.8080'
   , DATEFROMPARTS(1994,6,07)
   , 'AC_MGR'
   , 12000
   , NULL
   , 101
   , 110
   );
INSERT INTO ora_hr.employees VALUES 
   ( 206
   , 'William'
   , 'Gietz'
   , 'WGIETZ'
   , '515.123.8181'
   , DATEFROMPARTS(1994,6,07)
   , 'AC_ACCOUNT'
   , 8300
   , NULL
   , 205
   , 110
   );
-- ********* insert data into the JOB_HISTORY table
       
INSERT INTO ora_hr.job_history
         VALUES (102
   , DATEFROMPARTS(1993,1,13)
   , DATEFROMPARTS(1998,7,24)
   , 'IT_PROG'
   , 60);
INSERT INTO ora_hr.job_history
         VALUES (101
   , DATEFROMPARTS(1989,9,21)
   , DATEFROMPARTS(1993,10,27)
   , 'AC_ACCOUNT'
   , 110);
INSERT INTO ora_hr.job_history
         VALUES (101
   , DATEFROMPARTS(1993,10,28)
   , DATEFROMPARTS(1997,3,15)
   , 'AC_MGR'
   , 110);
INSERT INTO ora_hr.job_history
         VALUES (201
   , DATEFROMPARTS(1996,2,17)
   , DATEFROMPARTS(1999,12,19)
   , 'MK_REP'
   , 20);
INSERT INTO ora_hr.job_history
         VALUES (114
   , DATEFROMPARTS(1998,3,24)
   , DATEFROMPARTS(1999,12,31)
   , 'ST_CLERK'
   , 50
   );
INSERT INTO ora_hr.job_history
         VALUES (122
   , DATEFROMPARTS(1999,1,01)
   , DATEFROMPARTS(1999,12,31)
   , 'ST_CLERK'
   , 50
   );
INSERT INTO ora_hr.job_history
         VALUES (200
   , DATEFROMPARTS(1987,9,17)
   , DATEFROMPARTS(1993,6,17)
   , 'AD_ASST'
   , 90
   );
INSERT INTO ora_hr.job_history
         VALUES (176
   , DATEFROMPARTS(1998,3,24)
   , DATEFROMPARTS(1998,12,31)
   , 'SA_REP'
   , 80
   );
INSERT INTO ora_hr.job_history
         VALUES (176
   , DATEFROMPARTS(1999,1,01)
   , DATEFROMPARTS(1999,12,31)
   , 'SA_MAN'
   , 80
   );
INSERT INTO ora_hr.job_history
         VALUES (200
   , DATEFROMPARTS(1994,7,01)
   , DATEFROMPARTS(1998,12,31)
   , 'AC_ACCOUNT'
   , 90
   );
   
COMMIT TRANSACTION;
GO

--Add the departments constraint
ALTER TABLE ora_hr.departments
  ADD CONSTRAINT dept_mgr_fk
  FOREIGN KEY (manager_id) REFERENCES ora_hr.employees (employee_id);
  
GO
   
/*   
--Not implemented yet   
REM enable integrity constraint to DEPARTMENTS
ALTER TABLE departments 
   ENABLE CONSTRAINT dept_mgr_fk;
COMMIT;
CREATE INDEX emp_department_ix
   ON employees (department_id);
CREATE INDEX emp_job_ix
   ON employees (job_id);
CREATE INDEX emp_manager_ix
   ON employees (manager_id);
CREATE INDEX emp_name_ix
   ON employees (last_name, first_name);
CREATE INDEX dept_location_ix
   ON departments (location_id);
CREATE INDEX jhist_job_ix
   ON job_history (job_id);
CREATE INDEX jhist_employee_ix
   ON job_history (employee_id);
CREATE INDEX jhist_department_ix
   ON job_history (department_id);
CREATE INDEX loc_city_ix
   ON locations (city);
CREATE INDEX loc_state_province_ix 
   ON locations (state_province);
CREATE INDEX loc_country_ix
   ON locations (country_id);
COMMIT;
REM procedure and statement trigger to allow dmls during business hours:
         CREATE OR REPLACE PROCEDURE secure_dml
         IS
         BEGIN
   IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
   OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
   RAISE_APPLICATION_ERROR (-20205, 
   'You may only make changes during normal office hours');
   END IF;
   END secure_dml;
   /
CREATE OR REPLACE TRIGGER secure_employees
   BEFORE INSERT OR UPDATE OR DELETE ON employees
   BEGIN
   secure_dml;
   END secure_employees;
   /
ALTER TRIGGER secure_employees DISABLE;
REM **************************************************************************
REM procedure to add a row to the JOB_HISTORY table and row trigger 
REM to call the procedure when data is updated in the job_id or 
REM department_id columns in the EMPLOYEES table:
CREATE OR REPLACE PROCEDURE add_job_history
   ( p_emp_id job_history.employee_id%type
   , p_start_date job_history.start_date%type
   , p_end_date job_history.end_date%type
   , p_job_id job_history.job_id%type
   , p_department_id job_history.department_id%type 
   )
   IS
   BEGIN
   INSERT INTO ora_hr.job_history (employee_id, start_date, end_date, 
   job_id, department_id)
   VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
   END add_job_history;
   /
CREATE OR REPLACE TRIGGER update_job_history
   AFTER UPDATE OF job_id, department_id ON employees
   FOR EACH ROW
   BEGIN
   add_job_history(:old.employee_id, :old.hire_date, sysdate, 
   :old.job_id, :old.department_id);
   END;
   /
COMMIT;
COMMENT ON TABLE regions 
         IS 'Regions table that contains region numbers and names. Contains 4 rows; references with the Countries table.';
COMMENT ON COLUMN regions.region_id
         IS 'Primary key of regions table.';
COMMENT ON COLUMN regions.region_name
         IS 'Names of regions. Locations are in the countries of these regions.';
COMMENT ON TABLE locations
         IS 'Locations table that contains specific address of a specific office,
         warehouse, and/or production site of a company. Does not store addresses /
         locations of customers. Contains 23 rows; references with the
         departments and countries tables. ';
COMMENT ON COLUMN locations.location_id
         IS 'Primary key of locations table';
COMMENT ON COLUMN locations.street_address
         IS 'Street address of an office, warehouse, or production site of a company.
         Contains building number and street name';
COMMENT ON COLUMN locations.postal_code
         IS 'Postal code of the location of an office, warehouse, or production site 
         of a company. ';
COMMENT ON COLUMN locations.city
         IS 'A not null column that shows city where an office, warehouse, or 
         production site of a company is located. ';
COMMENT ON COLUMN locations.state_province
         IS 'State or Province where an office, warehouse, or production site of a 
         company is located.';
COMMENT ON COLUMN locations.country_id
         IS 'Country where an office, warehouse, or production site of a company is
         located. Foreign key to country_id column of the countries table.';
       
REM *********************************************
COMMENT ON TABLE departments
         IS 'Departments table that shows details of departments where employees 
         work. Contains 27 rows; references with locations, employees, and job_history tables.';
COMMENT ON COLUMN departments.department_id
         IS 'Primary key column of departments table.';
COMMENT ON COLUMN departments.department_name
         IS 'A not null column that shows name of a department. Administration, 
         Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public 
         Relations, Sales, Finance, and Accounting. ';
COMMENT ON COLUMN departments.manager_id
         IS 'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of the employee table references this column.';
COMMENT ON COLUMN departments.location_id
         IS 'Location id where a department is located. Foreign key to location_id column of locations table.';
       
REM *********************************************
COMMENT ON TABLE job_history
         IS 'Table that stores job history of the employees. If an employee 
         changes departments within the job or changes jobs within the department, 
         new rows get inserted into this table with old job information of the 
         employee. Contains a complex primary key: employee_id+start_date.
         Contains 25 rows. References with jobs, employees, and departments tables.';
COMMENT ON COLUMN job_history.employee_id
         IS 'A not null column in the complex primary key employee_id+start_date.
         Foreign key to employee_id column of the employee table';
COMMENT ON COLUMN job_history.start_date
         IS 'A not null column in the complex primary key employee_id+start_date. 
         Must be less than the end_date of the job_history table. (enforced by 
         constraint jhist_date_interval)';
COMMENT ON COLUMN job_history.end_date
         IS 'Last day of the employee in this job role. A not null column. Must be 
         greater than the start_date of the job_history table. 
         (enforced by constraint jhist_date_interval)';
COMMENT ON COLUMN job_history.job_id
         IS 'Job role in which the employee worked in the past; foreign key to 
         job_id column in the jobs table. A not null column.';
COMMENT ON COLUMN job_history.department_id
         IS 'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table';
       
REM *********************************************
COMMENT ON TABLE countries
         IS 'country table. Contains 25 rows. References with locations table.';
COMMENT ON COLUMN countries.country_id
         IS 'Primary key of countries table.';
COMMENT ON COLUMN countries.country_name
         IS 'Country name';
COMMENT ON COLUMN countries.region_id
         IS 'Region ID for the country. Foreign key to region_id column in the departments table.';
REM *********************************************
COMMENT ON TABLE jobs
         IS 'jobs table with job titles and salary ranges. Contains 19 rows.
         References with employees and job_history table.';
COMMENT ON COLUMN jobs.job_id
         IS 'Primary key of jobs table.';
COMMENT ON COLUMN jobs.job_title
         IS 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT';
COMMENT ON COLUMN jobs.min_salary
         IS 'Minimum salary for a job title.';
COMMENT ON COLUMN jobs.max_salary
         IS 'Maximum salary for a job title';
REM *********************************************
COMMENT ON TABLE employees
         IS 'employees table. Contains 107 rows. References with departments, 
         jobs, job_history tables. Contains a self reference.';
COMMENT ON COLUMN employees.employee_id
         IS 'Primary key of employees table.';
COMMENT ON COLUMN employees.first_name
         IS 'First name of the employee. A not null column.';
COMMENT ON COLUMN employees.last_name
         IS 'Last name of the employee. A not null column.';
COMMENT ON COLUMN employees.email
         IS 'Email id of the employee';
COMMENT ON COLUMN employees.phone_number
         IS 'Phone number of the employee; includes country code and area code';
COMMENT ON COLUMN employees.hire_date
         IS 'Date when the employee started on this job. A not null column.';
COMMENT ON COLUMN employees.job_id
         IS 'Current job of the employee; foreign key to job_id column of the 
         jobs table. A not null column.';
COMMENT ON COLUMN employees.salary
         IS 'Monthly salary of the employee. Must be greater 
         than zero (enforced by constraint emp_salary_min)';
COMMENT ON COLUMN employees.commission_pct
         IS 'Commission percentage of the employee; Only employees in sales 
         department elgible for commission percentage';
COMMENT ON COLUMN employees.manager_id
         IS 'Manager id of the employee; has same domain as manager_id in 
         departments table. Foreign key to employee_id column of employees table.
         (useful for reflexive joins and CONNECT BY query)';
COMMENT ON COLUMN employees.department_id
         IS 'Department id where employee works; foreign key to department_id 
         column of the departments table';
*/

