-- 03_analytics.sql
-- Analytical queries: grouping and summarizing data.
-- Run: sqlite3 -header -column db/emr.db < sql/queries/03_analytics.sql


-- A1: Number of visits for each encounter type, most common first.

SELECT e.encounter_type, COUNT(*) AS row_count
FROM encounters AS e
GROUP BY e.encounter_type
ORDER BY COUNT(*) DESC;


-- A2: Average pain score by encounter type, highest first.

SELECT encounter_type,
       COUNT(*)              AS responses,
       ROUND(AVG(answer), 2) AS avg_pain
FROM v_survey_answers
WHERE category = 'pain'
GROUP BY encounter_type
ORDER BY avg_pain DESC;

-- A3: Patients with 4 or more visits, most visits first.

SELECT p.patient_id, p.first_name, p.last_name, COUNT(*) AS visits
FROM patients AS p
JOIN encounters AS e
  ON e.patient_id = p.patient_id
GROUP BY p.patient_id
HAVING COUNT(*) >= 4
ORDER BY visits DESC, p.patient_id;


-- A4: Number of patients and average age for each sex, rounded to 1 decimal.
-- Columns: sex, patients, avg_age

SELECT p.sex,
       COUNT(*) AS patients,
       ROUND(AVG((julianday('now') - julianday(p.birth_date)) / 365.25), 1) AS avg_age
FROM patients AS p
GROUP BY p.sex
ORDER BY p.sex;

