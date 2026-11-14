-- 01_basics.sql
-- Basic queries: SELECT, WHERE, ORDER BY, LIMIT.
-- Run: sqlite3 -header -column db/emr.db < sql/queries/01_basics.sql

-- Q1: The 5 oldest female patients
SELECT first_name, last_name, birth_date
FROM patients
WHERE sex = 'F'
ORDER BY birth_date
LIMIT 5;

-- Q2: Show the 10 most recent encounters including their dates and the providers.
SELECT visit_date, encounter_id, encounter_type, provider_name
FROM encounters
ORDER BY visit_date DESC
LIMIT 10;

-- Q3: List all telehealth encounters by 'Patel, Ravi'. Include the encounter_id and visit_date.
SELECT encounter_id, visit_date
FROM encounters
WHERE provider_name = 'Patel, Ravi' AND encounter_type = 'telehealth'
ORDER BY visit_date DESC;
