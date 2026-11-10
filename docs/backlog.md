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

## Done

_Nothing yet._
