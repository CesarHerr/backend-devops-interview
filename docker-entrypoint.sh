#!/bin/sh
set -eu

python - <<'PY'
import os

import psycopg
from psycopg import sql

database_name = os.environ.get("DATABASE_NAME", "backend_devops_interview")
connection = psycopg.connect(
    dbname="postgres",
    user=os.environ.get("DATABASE_USER", "postgres"),
    password=os.environ.get("DATABASE_PASSWORD", "postgres"),
    host=os.environ.get("DATABASE_HOST", "localhost"),
    port=os.environ.get("DATABASE_PORT", "5432"),
    autocommit=True,
)

with connection:
    with connection.cursor() as cursor:
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (database_name,))
        if cursor.fetchone() is None:
            cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(database_name)))

connection.close()
PY

python manage.py migrate --noinput
python manage.py seed
exec python manage.py runserver 0.0.0.0:8000