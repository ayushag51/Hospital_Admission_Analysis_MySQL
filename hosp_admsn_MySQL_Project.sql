-- Selecting the Database
USE hosp_adm;

-- Exploratory Data Analysis (EDA)

-- To determine the total number of records in the dataset and identify the number of unique patients admitted to the hospital.
SELECT COUNT(*) AS total_records, COUNT(DISTINCT patient_id) AS unique_patients
FROM hospital_admissions;

-- To examine the dataset for missing or NULL values in key columns such as age, gender, department, and admission date in order to assess data completeness.
SELECT
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN department IS NULL THEN 1 ELSE 0 END) AS missing_department,
    SUM(CASE WHEN admission_date IS NULL THEN 1 ELSE 0 END) AS missing_admission_date
FROM hospital_admissions;

-- To analyze the minimum, maximum, and average age of patients admitted to the hospital.
SELECT MIN(age) AS min_age, MAX(age) AS max_age, ROUND(AVG(age),0) AS avg_age
FROM hospital_admissions;

-- To classify patients into age groups (Child, Adult, Senior) and analyze the distribution of admissions across these age groups.
SELECT 
CASE 
WHEN age<18 THEN 'child'
WHEN age>=18 AND age<=65 THEN 'adult'
ELSE 'senior'
END AS age_group, COUNT(*) AS no_of_patients
FROM hospital_admissions
GROUP BY age_group;

-- To analyze the gender-wise distribution of hospital admissions.
SELECT gender, COUNT(*) AS total_admissions_by_gender
FROM hospital_admissions
GROUP BY gender;

-- To identify the distribution of admissions across different hospital departments.
SELECT department, COUNT(*) AS admission_by_dept
FROM hospital_admissions
GROUP BY department
ORDER BY admission_by_dept DESC;

-- To examine the distribution of patient discharge outcomes(discharge to home, deceased, against medical advice).
SELECT discharge_status, COUNT(*) AS count
FROM hospital_admissions
GROUP BY discharge_status;

-- To analyze admission trends over time by studying monthly and yearly admission patterns.
SELECT
YEAR(admission_date) AS year,
MONTH(admission_date) AS month,
COUNT(*) AS admissions
FROM hospital_admissions
GROUP BY month,year
ORDER BY month,year;

-- To analyze the minimum, maximum, and average length of hospital stay for patients.
SELECT
MIN(DATEDIFF(discharge_date, admission_date)) AS min_stay,
MAX(DATEDIFF(discharge_date, admission_date)) AS max_stay,
ROUND(AVG(DATEDIFF(discharge_date, admission_date)), 1) AS avg_stay
FROM hospital_admissions;

-- To assess the distribution of workload among doctors by analyzing the number of cases handled by each doctor.
SELECT doctor_name, COUNT(*) AS cases_handled
FROM hospital_admissions
GROUP BY doctor_name
ORDER BY cases_handled DESC;


-- B. Core Data Analysis Problem Statements

-- To calculate the total number of hospital admissions recorded in the dataset.
SELECT COUNT(*) AS total_admissions
FROM hospital_admissions;

-- To analyze the number of patients admitted based on gender.
SELECT gender, COUNT(*) AS total_patients
FROM hospital_admissions
GROUP BY gender;

-- To identify departments with the highest and lowest number of patient admissions.
SELECT department, COUNT(*) AS admissions
FROM hospital_admissions
GROUP BY department
ORDER BY admissions DESC;

-- To analyze the distribution of discharge status across all hospital admissions.
SELECT discharge_status, COUNT(*) AS count
FROM hospital_admissions
GROUP BY discharge_status;

-- To calculate the average age of patients admitted in each department.
SELECT department, ROUND(AVG(age), 1) AS avg_age
FROM hospital_admissions
GROUP BY department;

-- To study the distribution of patients based on blood group.
SELECT blood_type, COUNT(*) AS patient_count
FROM hospital_admissions
GROUP BY blood_type
ORDER BY patient_count DESC;

-- To analyze monthly trends in hospital admissions to identify seasonal patterns.
SELECT
YEAR(admission_date) AS year_of_admission,
MONTH(admission_date) AS month_of_admission,
COUNT(*) AS admissions
FROM hospital_admissions
GROUP BY year_of_admission, month_of_admission
ORDER BY year_of_admission, month_of_admission;

-- To identify departments with number of patient transfers, home and deceased.
SELECT department, discharge_status, COUNT(*) AS count
FROM hospital_admissions
WHERE discharge_status IN ('Transfer', 'Home','Deceased')
GROUP BY department, discharge_status
ORDER BY department, count DESC;

-- To analyze the average length of stay for patients in each department.
SELECT department,
ROUND(AVG(DATEDIFF(discharge_date, admission_date)), 1) AS avg_stay
FROM hospital_admissions
GROUP BY department;

-- To identify the most common diagnoses among admitted patients.
SELECT primary_diagnosis, COUNT(*) AS count
FROM hospital_admissions
GROUP BY primary_diagnosis
ORDER BY count DESC
LIMIT 1;

-- To perform age-based analysis by categorizing patients into defined age groups and comparing admission counts.
SELECT
CASE
WHEN age < 18 THEN 'Child'
WHEN age BETWEEN 18 AND 65 THEN 'Adult'
ELSE 'Senior'
END AS age_group,
primary_diagnosis,
COUNT(*) AS total_patients
FROM hospital_admissions
GROUP BY age_group, primary_diagnosis
ORDER BY age_group;

-- To analyze the number of successful discharges (discharge to home) handled by each doctor.
SELECT doctor_name, COUNT(*) AS successful_discharges
FROM hospital_admissions
WHERE discharge_status='Home'
GROUP BY doctor_name
ORDER BY successful_discharges DESC;

-- To identify patients with multiple hospital admissions to understand readmission patterns.
SELECT patient_id, COUNT(*) AS admission_count
FROM hospital_admissions
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- To calculate the department-wise mortality rate.
SELECT
department, ROUND(SUM(CASE WHEN discharge_status = 'Deceased' THEN 1 ELSE 0 END)/ COUNT(*) * 100, 2) AS mortality_rate
FROM hospital_admissions
GROUP BY department;

-- To determine the day of the week with the highest number of hospital admissions.
SELECT DAYNAME(admission_date) AS weekdayName, COUNT(*) AS admissions
FROM hospital_admissions
GROUP BY weekdayName
ORDER BY admissions DESC;

-- To compare the average length of stay of each department with the overall hospital average and identify departments where patients stay longer than average
SELECT department,
ROUND(AVG(DATEDIFF(discharge_date, admission_date)), 2) AS dept_avg_stay
FROM hospital_admissions
GROUP BY department
HAVING dept_avg_stay >(
SELECT AVG(DATEDIFF(discharge_date, admission_date))
FROM hospital_admissions);

-- To classify doctors into performance categories based on the percentage of patients discharged successfully to home.
SELECT
doctor_name,
ROUND(SUM(CASE WHEN discharge_status = 'Home' THEN 1 ELSE 0 END)/ COUNT(*) * 100, 2) AS success_rate,
CASE
WHEN ROUND(SUM(CASE WHEN discharge_status = 'Home' THEN 1 ELSE 0 END)/ COUNT(*) * 100, 2) >= 80 THEN 'Excellent'
WHEN ROUND(SUM(CASE WHEN discharge_status = 'Home' THEN 1 ELSE 0 END)/ COUNT(*) * 100, 2) BETWEEN 60 AND 79 THEN 'Good'
ELSE 'Needs Attention'
END AS performance_category
FROM hospital_admissions
GROUP BY doctor_name;

-- To identify high-risk departments based on a combination of above-average mortality rate and longer than 14 days of hospital stays.
SELECT department,
ROUND(SUM(CASE WHEN discharge_status = 'Deceased' THEN 1 ELSE 0 END)/ COUNT(*) * 100, 2) AS mortality_rate,
ROUND(AVG(DATEDIFF(discharge_date, admission_date)), 2) AS avg_stay
FROM hospital_admissions
GROUP BY department
HAVING mortality_rate >
(
SELECT ROUND(SUM(CASE WHEN discharge_status = 'Deceased' THEN 1 ELSE 0 END)/COUNT(*) * 100, 2)
FROM hospital_admissions)
AND avg_stay > 14;

-- To analyze admission trends by quarter (Q1–Q4) and identify which quarter has the highest admissions for each department
SELECT department,
CASE
WHEN MONTH(admission_date) BETWEEN 1 AND 3 THEN 'Q1'
WHEN MONTH(admission_date) BETWEEN 4 AND 6 THEN 'Q2'
WHEN MONTH(admission_date) BETWEEN 7 AND 9 THEN 'Q3'
ELSE 'Q4'
END AS quarter,
COUNT(*) AS admissions
FROM hospital_admissions
GROUP BY department, quarter
ORDER BY department, admissions DESC;

-- To identify doctors whose average length of stay is lower than the overall hospital average, indicating efficient treatment outcomes.
SELECT
doctor_name,
AVG(DATEDIFF(discharge_date, admission_date)) AS avg_stay
FROM hospital_admissions
GROUP BY doctor_name
HAVING avg_stay < (
SELECT AVG(DATEDIFF(discharge_date, admission_date))
FROM hospital_admissions);
