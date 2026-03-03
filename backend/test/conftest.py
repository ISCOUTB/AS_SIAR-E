
import os, pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.pool import StaticPool
from app.main import create_app

@pytest.fixture(scope="session")
def test_client():
    # Usar SQLite en memoria para tests
    os.environ["DATABASE_URL"] = "sqlite+pysqlite:///:memory:"
    engine = create_engine(
        os.environ["DATABASE_URL"],
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    # Crear tablas mínimas (ejecutar sentencias por separado para SQLite)
    with engine.begin() as conn:
        conn.execute(text(
            """
            CREATE TABLE students (
              student_id VARCHAR(50) PRIMARY KEY,
              nombre VARCHAR(120) NOT NULL,
              programa VARCHAR(100),
              cohorte VARCHAR(20)
            )
            """
        ))
        conn.execute(text(
            "INSERT INTO students (student_id, nombre, programa, cohorte)"
            " VALUES (:id, :nombre, :programa, :cohorte)"
        ), {"id": "T001", "nombre": "Test User", "programa": "Test Program", "cohorte": "2025-1"})
    # Parchar el engine de la app para usar el de SQLite en memoria
    from app import db as appdb
    appdb.engine = engine
    appdb.SessionLocal.configure(bind=engine)

    app = create_app()
    client = TestClient(app)
    return client
