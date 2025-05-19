import pandas as pd
from grades import GRADE_MAPPING

# Загрузка файла
df = pd.read_csv("таблица_магистры.csv", encoding='cp1251', delimiter=';', engine='python')

# Извлечение строк: названия дисциплин и данные студентов
discipline_row_index = 5
student_start_index = 6

# Получение списка дисциплин
discipline_headers = df.iloc[discipline_row_index, 5:]
disciplines = [
    {"column_index": idx, "name_and_type": val}
    for idx, val in zip(discipline_headers.index, discipline_headers.values)
    if pd.notna(val)
]

# Извлечение студентов и их оценок
students_data = []
for _, row in df.iloc[student_start_index:].iterrows():
    student = {

        "number": row.iloc[0],
        "id": row.iloc[1],
        "name": row.iloc[2],
        "budget": row.iloc[3],
        "grades": {}
    }
    for disc in disciplines:
        col = disc["column_index"]
        student["grades"][disc["name_and_type"]] = GRADE_MAPPING.get(row[col], row[col])
    students_data.append(student)

print("Дисциплины:")
for d in disciplines:
    print(d["name_and_type"])

print("\nСтуденты:")
for s in students_data:  # первые 3 студента
    print(s["name"], s["grades"])
