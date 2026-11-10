CREATE TABLE patients (
    patient_id   INTEGER PRIMARY KEY,
    first_name   TEXT    NOT NULL,
    last_name    TEXT    NOT NULL,
    birth_date   TEXT    NOT NULL,          -- format: YYYY-MM-DD
    sex          TEXT    CHECK (sex IN ('F', 'M', 'X', 'U')),
    phone        TEXT,
    email        TEXT    UNIQUE,
    street       TEXT,
    city         TEXT,
    state        TEXT,
    zip_code     TEXT
);

CREATE TABLE encounters (
    encounter_id     INTEGER PRIMARY KEY,
    patient_id       INTEGER   NOT NULL,
    visit_date       TEXT      NOT NULL,          -- format: YYYY-MM-DD
    encounter_type   TEXT      CHECK (encounter_type IN ('office', 'telehealth', 'follow_up')),
    provider_name    TEXT,
    chief_complaint  TEXT,
    outcome          TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
);

CREATE TABLE survey_questions (
    question_id    INTEGER PRIMARY KEY,
    question_text  TEXT    NOT NULL UNIQUE,
    category       TEXT    NOT NULL          -- e.g. 'pain', 'sleep', 'mood'
);

CREATE TABLE survey_responses (
    response_id    INTEGER PRIMARY KEY,
    encounter_id   INTEGER    NOT NULL,
    question_id    INTEGER    NOT NULL,
    answer         INTEGER    NOT NULL,
    FOREIGN KEY (encounter_id) REFERENCES encounters (encounter_id),
    FOREIGN KEY (question_id) REFERENCES survey_questions (question_id)
);
