#!/bin/bash

# Настройки
DB_NAME=rating
DB_USER=postgres
SCHEMA_FILE=/tmp/schema.sql

# === СТРУКТУРА БД ===
cat > $SCHEMA_FILE <<EOF
CREATE TABLE ra_disc (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    shorttitle TEXT,
    department_id INTEGER CHECK (department_id IN (1,2,3,4,5))
);

CREATE TABLE ra_plan (
    id SERIAL PRIMARY KEY,
    level INTEGER CHECK (level IN (1,2)),
    year INTEGER NOT NULL
);

CREATE TABLE ra_control (
    id SERIAL PRIMARY KEY,
    plan_id INTEGER NOT NULL REFERENCES ra_plan(id),
    disc_id INTEGER NOT NULL REFERENCES ra_disc(id),
    sem INTEGER NOT NULL CHECK (sem >= 1 AND sem <= 8),
    form INTEGER NOT NULL,
    max_grade INTEGER DEFAULT 100
);

CREATE TABLE ra_version (
    id SERIAL PRIMARY KEY,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comment TEXT
);

CREATE TABLE ra_mark (
    id SERIAL PRIMARY KEY,
    version_id INTEGER NOT NULL REFERENCES ra_version(id),
    stud_id INTEGER NOT NULL,
    control_id INTEGER NOT NULL REFERENCES ra_control(id),
    grade INTEGER CHECK (
        grade IN (-9, -8, -7, -3, 0, 3, 4, 5)
        OR grade BETWEEN 1 AND 100
    )
);

CREATE TABLE ra_results (
    id SERIAL PRIMARY KEY,
    position INTEGER,
    stud_id INTEGER NOT NULL,
    cur_sem INTEGER,
    open_sem INTEGER,
    session_score INTEGER,
    total_score INTEGER,
    diff_score INTEGER,
    vega INTEGER,
    vm INTEGER,
    other INTEGER,
    percent REAL,
    diff_percent REAL
);

CREATE TABLE ra_cipher (
    student_cipher varchar(7) UNIQUE
    stud_id INTEGER NOT NULL
    name varchar (20)
    surname varchar (20)
    patronymic varchar (20)
)
EOF

# === Выполнение ===

# Создаём базу данных, если она не существует
psql -U $DB_USER -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;"

# Выполняем SQL-скрипт для создания таблиц
psql -U $DB_USER -d $DB_NAME -f $SCHEMA_FILE

# Очистка
rm $SCHEMA_FILE

echo "✅ Готово! База данных '$DB_NAME' создана и таблицы добавлены."