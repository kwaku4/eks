import os
import time
import logging

import psycopg2
from flask import Flask, jsonify

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("demo-app")

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASSWORD = os.environ.get("DB_PASSWORD")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=3,
    )


def ensure_table():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS visits (
                    id SERIAL PRIMARY KEY,
                    visited_at TIMESTAMPTZ NOT NULL DEFAULT now()
                );
                """
            )
        conn.commit()


@app.route("/health")
def health():
    """Liveness/readiness probe target. Checks DB connectivity too."""
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1;")
                cur.fetchone()
        return jsonify(status="ok", db="reachable"), 200
    except Exception as exc:  # noqa: BLE001 - health check reports any failure
        log.exception("health check failed")
        return jsonify(status="error", detail=str(exc)), 503


@app.route("/")
def index():
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO visits DEFAULT VALUES RETURNING id, visited_at;")
                row = cur.fetchone()
                cur.execute("SELECT count(*) FROM visits;")
                total = cur.fetchone()[0]
            conn.commit()
        return jsonify(
            message="Hello from the SRE take-home demo app!",
            visit_id=row[0],
            visited_at=row[1].isoformat(),
            total_visits=total,
        )
    except Exception as exc:  # noqa: BLE001
        log.exception("request failed")
        return jsonify(error=str(exc)), 500


if __name__ == "__main__":
    # Retry table creation briefly in case the app starts before RDS is reachable.
    for attempt in range(5):
        try:
            ensure_table()
            break
        except Exception:  # noqa: BLE001
            log.warning("DB not ready yet (attempt %s), retrying...", attempt + 1)
            time.sleep(3)

    app.run(host="0.0.0.0", port=8080)
