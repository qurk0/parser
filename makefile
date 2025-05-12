# Переменные
DOCKER_COMPOSE = docker compose
SERVICE = postgres
DB_CONTAINER = your_postgres_container

# Команды
up:
    $(DOCKER_COMPOSE) up -d

down:
    $(DOCKER_COMPOSE) down

build:
    $(DOCKER_COMPOSE) up --build -d

logs:
    $(DOCKER_COMPOSE) logs -f $(SERVICE)

psql:
    docker exec -it $(DB_CONTAINER) psql -U postgres -d rating

fill-db:
    docker exec -it $(DB_CONTAINER) bash -c "psql -U postgres -d rating -f /docker-entrypoint-initdb.d/init_and_dump.sh"

clean:
    $(DOCKER_COMPOSE) down -v
    rm -rf ./postgres_data

help:
    @echo "Доступные команды:"
    @echo "  up         - Запустить контейнеры"
    @echo "  down       - Остановить контейнеры"
    @echo "  build      - Собрать и запустить контейнеры"
    @echo "  logs       - Просмотреть логи сервиса postgres"
    @echo "  psql       - Подключиться к базе данных через psql"
    @echo "  fill-db    - Заполнить базу данных"
    @echo "  clean      - Удалить контейнеры и данные"