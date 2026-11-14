-- 02_joins.sql
-- JOIN queries: combining tables through their foreign keys.
-- Run: sqlite3 -header -column db/emr.db < sql/queries/02_joins.sql

-- J1: All visits for patient 2.
-- Run: sqlite3 -header -column db/emr.db < sql/queries/02_joins.sql

SELECT p.first_name, p.last_name, e.visit_date, e.encounter_type
FROM patients AS p
JOIN encounters AS e
  ON e.patient_id = p.patient_id
WHERE p.patient_id = 2
ORDER BY e.visit_date;

-- J2: All of Renee Blair’s (patient 2) pain scores.
SELECT p.first_name, p.last_name, e.encounter_id, e.visit_date, q.question_text, r.answer
FROM encounters AS e
JOIN patients AS p
  ON e.patient_id = p.patient_id
JOIN survey_responses AS r
  ON r.encounter_id = e.encounter_id
JOIN survey_questions AS q
  ON r.question_id = q.question_id
WHERE p.patient_id = 2
    AND q.category = 'pain'
ORDER BY e.visit_date;
