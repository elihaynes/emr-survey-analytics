# Data Dictionary

## patients

One row per patient. Stores demographic and contact information.

| Column | Type | Required | Description | Allowed values / format |
|---|---|---|---|---|
| patient_id | INTEGER | Yes | Unique patient identifier (primary key). Auto-assigned. | 1, 2, 3, ... |
| first_name | TEXT | Yes | Patient's legal first name. | |
| last_name | TEXT | Yes | Patient's legal last name. | |
| birth_date | TEXT | Yes | Date of birth. | `YYYY-MM-DD` |
| sex | TEXT | No | Sex recorded at registration. | `F`, `M`, `X`, `U` (unknown) |
| phone | TEXT | No | Primary contact phone number. | |
| email | TEXT | No | Contact email. Must be unique across patients. | |
| street | TEXT | No | Street address. | |
| city | TEXT | No | City of residence. | |
| state | TEXT | No | State of residence. | 2-letter code, e.g. `OH` |
| zip_code | TEXT | No | ZIP code. Stored as text to keep leading zeros. | 5 digits, e.g. `02108` |

## encounters

One row per encounter (a single patient visit). Links to the patient via patient_id.

| Column | Type | Required | Description | Allowed values / format |
|---|---|---|---|---|
| encounter_id | INTEGER | Yes | Encounter identifier (primary key). Auto-assigned. | 1, 2, 3, ... |
| patient_id | INTEGER | Yes | The patient seen at this visit (foreign key → `patients.patient_id`). Repeats when a patient has multiple visits. | Must match an existing `patient_id` |
| visit_date | TEXT | Yes | Date of patient visit. | `YYYY-MM-DD` |
| encounter_type | TEXT | No | Type of patient visit. | `office`, `telehealth`, or `follow_up` |
| provider_name | TEXT | No | Name of the clinician who saw the patient. | Last_name, First_name, e.g., `Smith, John` |
| chief_complaint | TEXT | No | Primary reason for patient seeking care. | free text |
| outcome | TEXT | No | Outcome of the visit and/or next steps. | free text |

## survey_questions

One row per survey question. Defines the questions patients can be asked.

| Column | Type | Required | Description | Allowed values / format |
|---|---|---|---|---|
| question_id | INTEGER | Yes | Question identifier (primary key). Auto-assigned. | 1, 2, 3, ... |
| question_text | TEXT | Yes | Question delivered to the patient. Must be unique. | free text |
| category | TEXT | Yes | Nature of clinical question. | free text, e.g., `pain`, `sleep`, `mood` |

## survey_responses

One row per answer: one patient’s answer to one question at one encounter.

| Column | Type | Required | Description | Allowed values / format |
|---|---|---|---|---|
| response_id | INTEGER | Yes | Response identifier (primary key). Auto-assigned. | 1, 2, 3, ... |
| encounter_id | INTEGER | Yes | The encounter during which the survey was completed (foreign key → `encounters.encounter_id`). | Must match an existing `encounter_id` |
| question_id | INTEGER | Yes | The survey question being answered (foreign key → `survey_questions.question_id`). | Must match an existing `question_id` |
| answer | INTEGER | Yes | Patient's response to the survey question. | Whole number. Scale depends on the question; see `survey_questions.question_text`. |
