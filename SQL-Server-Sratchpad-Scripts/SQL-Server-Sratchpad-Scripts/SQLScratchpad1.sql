-- Change employee 100 to report to a different manager
UPDATE ora_hr.employees
   SET manager_id = 100
 WHERE employee_id = 110;

-- Change the manager of department 100 to remove their department
UPDATE e
   SET e.department_id = NULL
  FROM ora_hr.departments AS d
  JOIN ora_hr.employees AS e 
    ON d.manager_id = e.employee_id
 WHERE d.department_id = 100;

-- Select employees that are in department 100 or the manager of department 100
SELECT e.employee_id AS emp_id,
       CONCAT(e.first_name, ' ', e.last_name) AS emp_name,
       e.department_id AS emp_dept_id, 
       e.manager_id AS emp_mgr_id,
       d.manager_id AS dept_mgr_id
  FROM ora_hr.departments AS d
  JOIN ora_hr.employees AS e
    ON d.manager_id = e.employee_id
    OR d.department_id = e.department_id
 WHERE d.department_id = 100;

 SELECT orderid, orderyear, nextyear
   FROM sales.orders AS o
   CROSS APPLY(VALUES(YEAR(o.orderdate))) AS a1(orderyear)
   CROSS APPLY(VALUES(orderyear +1)) AS a2(nextyear)
  WHERE orderyear > 2006;