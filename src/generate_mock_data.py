"""Generate mock EMR survey data as CSV files in data/raw/.

All data is synthetic (created with Faker). It contains no real patient information.
"""

import csv
import random
from pathlib import Path

from faker import Faker

# ---- Settings ----
SEED = 42
NUM_PATIENTS = 200
OUTPUT_DIR = Path("data/raw")

fake = Faker("en_US")
Faker.seed(SEED)
random.seed(SEED)

# ---- Reference lists ----
ENCOUNTER_TYPES = ["office", "telehealth", "follow_up"]
PROVIDERS = ["Nguyen, Linh", "Patel, Ravi", "Okafor, Grace", "Schmidt, Daniel", "Alvarez, Maria"]
CHIEF_COMPLAINTS = ["Lower back pain", "Headache", "Joint pain", "Fatigue",
                    "Trouble sleeping", "Anxiety", "Annual checkup"]
OUTCOMES = ["Prescribed medication", "Referred to specialist", "Physical therapy ordered",
            "Follow-up scheduled", "No action needed"]
SURVEY_QUESTIONS = [
    {"question_id": 1, "question_text": "Pain level (0-10)",    "category": "pain",  "min": 0, "max": 10},
    {"question_id": 2, "question_text": "Sleep quality (1-5)",  "category": "sleep", "min": 1, "max": 5},
    {"question_id": 3, "question_text": "Mood (1-5)",           "category": "mood",  "min": 1, "max": 5},
    {"question_id": 4, "question_text": "Anxiety level (0-10)", "category": "mood",  "min": 0, "max": 10},
]

def write_csv(filename, rows):
    """Write a list of dictionaries to a CSV file in OUTPUT_DIR."""
    path = OUTPUT_DIR / filename
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {len(rows):>5} rows -> {path}")


def generate_patients(n):
    """Create n fake patients."""
    patients = []
    for patient_id in range(1, n + 1):
        sex = random.choices(["F", "M", "X", "U"], weights=[48, 48, 2, 2])[0]
        first_name = fake.first_name_female() if sex == "F" else fake.first_name_male()
        patients.append({
            "patient_id": patient_id,
            "first_name": first_name,
            "last_name": fake.last_name(),
            "birth_date": fake.date_of_birth(minimum_age=18, maximum_age=90).isoformat(),
            "sex": sex,
            "phone": fake.phone_number(),
            "email": fake.unique.email(),
            "street": fake.street_address(),
            "city": fake.city(),
            "state": fake.state_abbr(),
            "zip_code": fake.zipcode(),
        })
    return patients


def generate_encounters(patients):
    """Create 1-5 encounters (visits) per patient."""
    encounters = []
    encounter_id = 1
    for patient in patients:
        num_visits = random.randint(1, 5)
        for _ in range(num_visits):
            encounters.append({
                "encounter_id": encounter_id,
                "patient_id": patient["patient_id"],
                "visit_date": fake.date_between(start_date="-2y", end_date="today").isoformat(),
                "encounter_type": random.choice(ENCOUNTER_TYPES),
                "provider_name": random.choice(PROVIDERS),
                "chief_complaint": random.choice(CHIEF_COMPLAINTS),
                "outcome": random.choice(OUTCOMES),
            })
            encounter_id += 1
    return encounters


def generate_questions():
    """Return survey questions in the shape of the survey_questions table."""
    return [
        {"question_id": q["question_id"],
         "question_text": q["question_text"],
         "category": q["category"]}
        for q in SURVEY_QUESTIONS
    ]


def generate_responses(encounters):
    """Create one answer per survey question for each encounter."""
    responses = []
    response_id = 1
    for encounter in encounters:
        for question in SURVEY_QUESTIONS:
            responses.append({
                "response_id": response_id,
                "encounter_id": encounter["encounter_id"],
                "question_id": question["question_id"],
                "answer": random.choice(range(question["min"], question["max"] + 1)),
            })
            response_id += 1
    return responses


def main():
    patients = generate_patients(NUM_PATIENTS)
    encounters = generate_encounters(patients)
    survey_questions = generate_questions()
    responses = generate_responses(encounters)

    write_csv("patients.csv", patients)
    write_csv("encounters.csv", encounters)
    write_csv("survey_questions.csv", survey_questions)
    write_csv("survey_responses.csv", responses)


if __name__ == "__main__":
    main()
