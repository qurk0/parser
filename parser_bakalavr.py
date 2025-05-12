from bs4 import BeautifulSoup
from grades import GRADE_MAPPING
from dotenv import load_dotenv
import psycopg2
import os

# Загрузка переменных из .env
load_dotenv()

# Настройки подключения к БД
DB_CONFIG = {
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT"),
}


def check_disciplines_in_db(disciplines, conn):
    with conn.cursor() as cursor:
        for discipline in disciplines:
            cursor.execute("SELECT id FROM ra_disc WHERE id = %s", (discipline["id"],))
            if cursor.fetchone() is None:
                print(f"Дисциплина отсутствует в БД: {discipline['title']} (ID: {discipline['id']})")

def normalize_grade(grade_text):
    return GRADE_MAPPING.get(grade_text.strip(), None)

def parse_html(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        soup = BeautifulSoup(file, "html.parser")

    # Парсинг дисциплин
    disciplines = []
    discipline_headers = soup.select(".v-text")
    for header in discipline_headers:
        text = header.get_text(strip=True).replace("\n", " ")
        if "№" in text:
            parts = text.split("№")
            title = parts[0].strip().replace("\n", " ")
            disc_id = int(parts[1].strip())
            accreditation_type = header.find_previous("div", class_="sh-simple-list-header-column-content").get_text(strip=True)
            disciplines.append({"id": disc_id, "title": title, "type": accreditation_type})

    # Парсинг студентов и их оценок
    students = []
    rows = soup.select(".sh-simple-list-row-odd, .sh-simple-list-row-even")
    for row in rows:
        student_id = row.select_one("td:nth-of-type(3)").get_text(strip=True)
        grades = [normalize_grade(cell.get_text(strip=True)) for cell in row.select("td div.cell-link div")]
        students.append({"id": student_id, "grades": grades})

    return disciplines, students

def display_data(disciplines, students):
    print("\n=== Дисциплины ===")
    for discipline in disciplines:
        print(f"ID: {discipline['id']}, Название: {discipline['title']}, Тип аккредитации: {discipline['type']}")

    print("\n=== Студенты и их оценки ===")
    for student in students:
        grades = ", ".join(str(grade) for grade in student["grades"] if grade is not None)
        print(f"ID студента: {student['id']}, Оценки: {grades}")

def main():
    html_file = "страница_бакалавры.html"

    # Парсинг HTML
    disciplines, students = parse_html(html_file)

    # Вывод данных в терминал
    display_data(disciplines, students)

if __name__ == "__main__":
    main()
    