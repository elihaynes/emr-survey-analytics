-- 03_analytics.sql
-- Analytical queries: grouping and summarizing data.
-- Run: sqlite3 -header -column db/emr.db < sql/queries/03_analytics.sql


-- A1: Number of visits for each encounter type, most common first.

SELECT e.encounter_type, COUNT(*) AS row_count
FROM encounters AS e
GROUP BY e.encounter_type
ORDER BY COUNT(*) DESC;


-- A2: Average pain score by encounter type, highest first.

SELECT e.encounter_type,
       COUNT(*)                 AS responses,
       ROUND(AVG(r.answer), 2)      AS avg_pain
FROM encounters AS e
JOIN survey_responses AS r
  ON r.encounter_id = e.encounter_id
JOIN survey_questions AS q
  ON r.question_id = q.question_id
WHERE q.category = 'pain'
GROUP BY e.encounter_type
ORDER BY avg_pain DESC;
