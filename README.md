# EMR Survey Analytics

A SQLite-based portal for ingesting, querying, and analyzing mock patient survey data structured like an Electronic Medical Record (EMR).

This is a learning project, built with guidance from Claude, to practice SQL, Git/GitHub workflows, and technical documentation.

## How to run

Run every command from the project root folder.

1. **Set up Python** (first time only):

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Generate the mock data** (writes CSV files to `data/raw/`):

   ```bash
   python src/generate_mock_data.py
   ```

3. **Load the data into SQLite** (rebuilds `db/emr.db` from scratch):

   ```bash
   mkdir -p db
   python src/load_data.py
   ```

4. **Create the views.** Do this after every load, because step 3 deletes them:

   ```bash
   sqlite3 db/emr.db < sql/views/v_survey_answers.sql
   ```

5. **Run the queries:**

   ```bash
   sqlite3 -header -column db/emr.db < sql/queries/03_analytics.sql
   ```

All data is synthetic, generated with Faker. It contains no real patient information.
