-- v_survey_answers.sql
-- One row per survey answer, with visit, question, and patient context.
-- No direct identifiers (names, contact details): minimum necessary.

DROP VIEW IF EXISTS v_survey_answers;

CREATE VIEW v_survey_answers AS
SELECT
    r.response_id,
    e.patient_id,
    e.encounter_id,
    e.visit_date,
    e.encounter_type,
    e.provider_name,
    e.chief_complaint,
    p.sex,
    ROUND((julianday('now') - julianday(p.birth_date)) / 365.25, 1) AS age,
    q.question_id,
    q.question_text,
    q.category,
    r.answer
FROM survey_responses AS r
JOIN encounters AS e
  ON e.encounter_id = r.encounter_id
JOIN survey_questions AS q
  ON q.question_id = r.question_id
JOIN patients AS p
  ON p.patient_id = e.patient_id;
