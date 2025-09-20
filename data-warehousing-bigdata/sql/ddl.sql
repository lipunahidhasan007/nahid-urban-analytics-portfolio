-- PostgreSQL DDL for HR Analytics Star Schema

CREATE TABLE IF NOT EXISTS dim_department (
  department_id SERIAL PRIMARY KEY,
  department TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_job_title (
  job_id SERIAL PRIMARY KEY,
  job_title TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_education_level (
  education_id SERIAL PRIMARY KEY,
  education_level TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_time (
  time_id SERIAL PRIMARY KEY,
  hire_date DATE NOT NULL,
  year INT NOT NULL,
  month INT NOT NULL,
  quarter INT NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_employee_performance (
  employee_id INT PRIMARY KEY,
  department_id INT REFERENCES dim_department(department_id),
  job_id INT REFERENCES dim_job_title(job_id),
  education_id INT REFERENCES dim_education_level(education_id),
  time_id INT REFERENCES dim_time(time_id),
  monthly_salary NUMERIC,
  performance_score NUMERIC,
  employee_satisfaction NUMERIC,
  resigned BOOLEAN,
  remote_work_frequency INT,
  training_hours INT,
  promotions INT,
  sick_days INT
);