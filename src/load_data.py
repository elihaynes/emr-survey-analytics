"""Load mock EMR CSV files from data/raw/ into the SQLite database.

Rebuilds db/emr.db from scratch on every run: deletes the old database,
creates empty tables from the schema, then loads each CSV.
"""

import csv
import sqlite3
from pathlib import Path

DB_PATH = Path("db/emr.db")
SCHEMA_PATH = Path("sql/schema/001_create_tables.sql")
DATA_DIR = Path("data/raw")

# Parent tables must load before the child tables that point to them.
LOAD_ORDER = ["patients", "encounters", "survey_questions", "survey_responses"]


def create_database():
    """Delete any existing database and build empty tables from the schema."""
    if DB_PATH.exists():
        DB_PATH.unlink()                       # delete the old file
    conn = sqlite3.connect(DB_PATH)            # creates a new, empty file
    conn.execute("PRAGMA foreign_keys = ON")     # enforce foreign key constraints
    conn.executescript(SCHEMA_PATH.read_text())  # runs your CREATE TABLE file
    return conn


def load_table(conn, table):
    """Insert every row of data/raw/<table>.csv into <table>. Return the row count."""
    path = DATA_DIR / f"{table}.csv"
    with open(path, newline="") as f:
        reader = csv.DictReader(f)
        columns = reader.fieldnames
        placeholders = ", ".join("?" for _ in columns)
        sql = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})"
        rows = [tuple(row[c] for c in columns) for row in reader]
    conn.executemany(sql, rows)
    return len(rows)


def main():
    conn = create_database()
    try:
        with conn:  # one transaction: every table loads, or none do
            for table in LOAD_ORDER:
                count = load_table(conn, table)
                print(f"Loaded {count:>5} rows -> {table}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()