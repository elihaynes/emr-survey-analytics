# Feature Backlog

Ideas and improvements to build later. Each item becomes its own feature branch and Pull Request when picked up (see Phase 4).

## How to use this file

- **Add** an item whenever an idea or gap comes up. Don't stop current work to build it.
- **Pick up** an item by creating a branch named after its ID, e.g. `feature/BL-001-score-ranges`.
- **Close** an item by moving it to the Done section with a link to its Pull Request.

**Priority:** `High` = blocks correct analysis · `Medium` = improves quality · `Low` = nice to have

## Open

### BL-001: Store valid score ranges for survey questions

- **Priority:** High
- **Found during:** Phase 2, data dictionary review
- **Problem:** Each question's valid answer range (e.g. 0–10 for pain, 1–5 for sleep) exists only in the question's wording. The database can't validate answers, and analysts must parse text to interpret scores.
- **Proposed change:** Add `min_score` and `max_score` columns to `survey_questions`. Enforce that each `survey_responses.answer` falls within its question's range.
- **Acceptance criteria:**
  - [ ] Schema updated with the new columns
  - [ ] Inserting an out-of-range answer is rejected
  - [ ] Data dictionary updated

### BL-002: Standardize patient phone number format

- **Priority:** Medium
- **Found during:** Phase 3, reviewing generated `patients.csv`
- **Problem:** Phone numbers arrive in inconsistent formats, e.g. `321.581.9600`, `(518)349-5931x0341`. Some include extensions. Inconsistent formats make searching, deduplication, and contacting patients unreliable. Real EMR data has the same problem because different staff enter data differently.
- **Proposed change:** Clean phone numbers during ingestion into one standard format (e.g. `555-555-5555`), storing any extension in a separate `phone_ext` column. Flag numbers that can't be parsed instead of silently dropping them.
- **Acceptance criteria:**
  - [ ] All loaded phone numbers match the standard format
  - [ ] Extensions preserved in their own column
  - [ ] Unparseable numbers reported in the load output
  - [ ] Schema and data dictionary updated

### BL-003: Support British Columbia, Canada addresses in mock data

- **Priority:** Medium
- **Found during:** Phase 3, reviewing generated `patients.csv`
- **Problem:** The generator produces US addresses (`state`, 5-digit `zip_code`). The portal should be able to model patients in British Columbia, Canada, which uses municipalities, provinces, and postal codes in the format `A1A 1A1`.
- **Proposed change:**
  - Generate addresses with Faker's Canadian locale (`en_CA`), restricted to BC municipalities (e.g. Vancouver, Surrey, Victoria, Kelowna) and province `BC`.
  - Rename address columns to location-neutral names: `state` → `province`, `zip_code` → `postal_code`, and decide whether `city` should become `municipality`.
  - Validate postal code format (`A1A 1A1`) and BC's postal prefix (`V`).
- **Acceptance criteria:**
  - [ ] Generated patients have BC municipalities, province `BC`, and valid `V#A #A#` postal codes
  - [ ] Schema columns renamed, with all scripts and queries updated to match
  - [ ] Data dictionary updated (column names, formats, examples)

### BL-004: Simulate skipped survey answers in mock data

- **Priority:** Medium
- **Found during:** Phase 3, sanity-checking generated row counts
- **Problem:** The generator answers every survey question at every encounter, so `survey_responses = encounters × 4` always holds. Real patients skip questions, run out of time, or decline to answer. Analysis and validation built on perfectly complete mock data may break, or give misleading results, on real data.
- **Proposed change:**
  - Make the generator randomly skip a configurable share of answers (e.g. `SKIP_RATE = 0.05`).
  - Replace the `responses = encounters × 4` check with checks that stay valid when answers are missing: no encounter has **more than** one response per question, and report the share of missing answers.
  - Document each validation check's assumptions alongside the check. A check that's only valid under certain assumptions should say so.
- **Acceptance criteria:**
  - [ ] Generator skips roughly `SKIP_RATE` of answers, reproducibly with the fixed seed
  - [ ] Validation queries detect duplicate answers and report missing-answer rates
  - [ ] Each validation check states its assumptions
  - [ ] Analytical queries handle missing answers deliberately (documented decision on how averages treat skipped questions)

### BL-005: Combine validation row counts into a single result table

- **Priority:** Low
- **Found during:** Phase 3, Step 3.4 (post-load validation)
- **Problem:** Check 1 in `sql/queries/00_validation.sql` runs four separate `COUNT(*)` queries, so the output repeats the header four times and is harder to scan or paste into a load log.
- **Proposed change (option):** Replace the four queries with one `UNION ALL` statement that stacks the counts into a single table:

  ```sql
  SELECT 'patients' AS table_name, COUNT(*) AS row_count FROM patients
  UNION ALL
  SELECT 'encounters', COUNT(*) FROM encounters
  UNION ALL
  SELECT 'survey_questions', COUNT(*) FROM survey_questions
  UNION ALL
  SELECT 'survey_responses', COUNT(*) FROM survey_responses;
  ```

  Only the first `SELECT` needs aliases, and the whole statement ends with a single semicolon.
- **Acceptance criteria:**
  - [ ] Check 1 output is one table with one header and four rows
  - [ ] Expected counts comment still matches the output

### BL-006: Modular patient name fields

- **Priority:** Medium
- **Found during:** Phase 3, Step 3.5 (external suggestion)
- **Problem:** `patients` stores names as `first_name` and `last_name` only. That can't represent middle names, suffixes (e.g. `Jr.`, `III`), or the name a patient prefers to be called. "First" and "last" also assume a name order that many cultures don't use; some place the family name first. EMRs need structured names for sorting, matching records, and legal documents.
- **Proposed change:**
  - Replace `first_name` / `last_name` with modular fields: `given_name`, `middle_names`, `family_name`, `suffix`, `preferred_name`.
  - `given_name` and `family_name` required; `middle_names`, `suffix`, and `preferred_name` **optional** (`NULL` allowed).
  - Use "given" and "family" rather than "first" and "last" so the fields don't assume a name order.
  - Consider the same structure for `encounters.provider_name`, currently a single `Last, First` text field.
- **Acceptance criteria:**
  - [ ] Schema updated with the new name columns and correct `NOT NULL` rules
  - [ ] Generator produces some patients with middle names, suffixes, and preferred names, and some without
  - [ ] Loader, queries, and validation checks updated to the new column names
  - [ ] Data dictionary updated

### BL-007: Recreate views automatically when the database is rebuilt

- **Priority:** Medium
- **Found during:** Phase 3, Step 3.8 (views)
- **Problem:** `src/load_data.py` deletes and rebuilds `db/emr.db`, which also deletes every view (e.g. `v_survey_answers`). After each reload, views must be recreated by hand. If someone forgets, queries that use a view fail with "no such table."
- **Proposed change:** After loading the data, have the loader run every `.sql` file in `sql/views/` (in a fixed order, e.g. sorted by filename) and print each view it created.
- **Acceptance criteria:**
  - [ ] Running the loader once produces a database with all tables **and** all views
  - [ ] `SELECT COUNT(*) FROM v_survey_answers;` returns 2384 right after a fresh load
  - [ ] Loader output lists the views it created
  - [ ] A broken view file stops the load with a clear error

## Done

### BL-008: Create the database folder automatically on load

- **Priority:** Low
- **Pull Request:** [#1](https://github.com/elihaynes/emr-survey-analytics/pull/1)
- **Found during:** Phase 3, testing the README run steps in a fresh clone
- **Problem:** `db/` isn't tracked by Git (`*.db` is ignored and the folder has no `.gitkeep`), so a fresh clone has no `db/` folder. Running `src/load_data.py` then crashes with "unable to open database file." For now the README works around this with a manual `mkdir -p db` step, which is easy to forget.
- **Proposed change:**
  - In `create_database()`, create the folder before connecting: `DB_PATH.parent.mkdir(parents=True, exist_ok=True)`.
  - Remove the `mkdir -p db` line from step 3 of the README's "How to run" section, since the loader handles it.
- **Acceptance criteria:**
  - [x] In a fresh clone with no `db/` folder, `python src/load_data.py` succeeds and creates `db/emr.db`
  - [x] Running the loader when `db/` already exists still works
  - [x] README step 3 no longer includes `mkdir -p db`, and the remaining steps still work in a fresh clone
