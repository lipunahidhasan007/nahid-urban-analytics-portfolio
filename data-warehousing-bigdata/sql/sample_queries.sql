-- STAGING LOAD (example)
-- CREATE TABLE staging_employee AS SELECT * FROM ...;
-- COPY staging_employee FROM '/path/to/Cleaned_Extended_Employee_Performance_and_Productivity_Data.csv' CSV HEADER;

-- DIM POPULATION
INSERT INTO dim_department(department)
SELECT DISTINCT department FROM staging_employee
ON CONFLICT (department) DO NOTHING;

INSERT INTO dim_job_title(job_title)
SELECT DISTINCT job_title FROM staging_employee
ON CONFLICT (job_title) DO NOTHING;

INSERT INTO dim_education_level(education_level)
SELECT DISTINCT education_level FROM staging_employee
ON CONFLICT (education_level) DO NOTHING;

INSERT INTO dim_time(hire_date, year, month, quarter)
SELECT DISTINCT hire_date,
       EXTRACT(YEAR FROM hire_date)::INT,
       EXTRACT(MONTH FROM hire_date)::INT,
       CEIL(EXTRACT(MONTH FROM hire_date)/3.0)::INT
FROM staging_employee
WHERE hire_date IS NOT NULL
ON CONFLICT DO NOTHING;

-- FACT POPULATION (FK lookups)
INSERT INTO fact_employee_performance (
  employee_id, department_id, job_id, education_id, time_id,
  monthly_salary, performance_score, employee_satisfaction,
  resigned, remote_work_frequency, training_hours, promotions, sick_days
)
SELECT
  s.employee_id,
  d.department_id,
  j.job_id,
  e.education_id,
  t.time_id,
  s.monthly_salary,
  s.performance_score,
  s.employee_satisfaction,
  s.resigned,
  s.remote_work_frequency,
  s.training_hours,
  s.promotions,
  s.sick_days
FROM staging_employee s
JOIN dim_department d ON d.department = s.department
JOIN dim_job_title j ON j.job_title = s.job_title
JOIN dim_education_level e ON e.education_level = s.education_level
JOIN dim_time t ON t.hire_date = s.hire_date;

-- KPI EXAMPLES
-- Total employees
SELECT COUNT(*) AS total_employees FROM fact_employee_performance;

-- Resigned employees
SELECT COUNT(*) AS resigned_employees FROM fact_employee_performance WHERE resigned = TRUE;

-- Average satisfaction & salary
SELECT AVG(employee_satisfaction) AS avg_satisfaction, AVG(monthly_salary) AS avg_salary
FROM fact_employee_performance;

-- VISUALS SUPPORT
-- Resignations by Department
SELECT d.department, SUM(CASE WHEN f.resigned THEN 1 ELSE 0 END) AS resigned_count
FROM fact_employee_performance f
JOIN dim_department d ON d.department_id = f.department_id
GROUP BY d.department
ORDER BY resigned_count DESC;

-- Hiring Trend by Year
SELECT t.year, COUNT(*) AS hires
FROM fact_employee_performance f
JOIN dim_time t ON t.time_id = f.time_id
GROUP BY t.year
ORDER BY t.year;

-- Average Satisfaction by Job Title
SELECT j.job_title, AVG(f.employee_satisfaction) AS avg_satisfaction
FROM fact_employee_performance f
JOIN dim_job_title j ON j.job_id = f.job_id
GROUP BY j.job_title
ORDER BY avg_satisfaction DESC;

-- Salary vs Performance (raw points)
SELECT f.performance_score, f.monthly_salary, j.job_title, d.department
FROM fact_employee_performance f
JOIN dim_job_title j ON j.job_id = f.job_id
JOIN dim_department d ON d.department_id = f.department_id;