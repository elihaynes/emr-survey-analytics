-- 00_validation.sql
-- Post-load validation checks for db/emr.db.
-- Run after every load: sqlite3 -header -column db/emr.db < sql/queries/00_validation.sql

-- Check 1: Row counts per table
-- Expected (seed 42): patients 200, encounters 596, survey_questions 4, survey_responses 2384
SELECT 'patients' AS table_name, COUNT(*) AS row_count
FROM patients;

SELECT 'encounters' AS table_name, COUNT(*) AS row_count
FROM encounters;

SELECT 'survey_questions' AS table_name, COUNT(*) AS row_count
FROM survey_questions;

SELECT 'survey_responses' AS table_name, COUNT(*) AS row_count
FROM survey_responses;

-- Check 2: Orphan records (foreign keys pointing to rows that don't exist)
-- Expected: no output
PRAGMA foreign_key_check;

-- Check 3: Answers outside their question's valid scale
-- Expected: bad_answers = 0
SELECT COUNT(*) AS bad_answers
FROM survey_responses
WHERE (question_id IN (2, 3) AND answer NOT BETWEEN 1 AND 5)
   OR (question_id IN (1, 4) AND answer NOT BETWEEN 0 AND 10);
   