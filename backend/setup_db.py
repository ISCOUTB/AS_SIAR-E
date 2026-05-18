import sqlalchemy as sa
from app.db import engine

with engine.connect() as conn:
    conn.execute(sa.text("DROP TABLE IF EXISTS students"))
    conn.execute(sa.text("DROP TABLE IF EXISTS alerts"))
    conn.execute(sa.text("DROP TABLE IF EXISTS users"))

    conn.execute(sa.text("""
        CREATE TABLE students (
            student_id TEXT PRIMARY KEY,
            nombre TEXT,
            programa TEXT,
            cohorte TEXT,
            semestre INTEGER,
            notas REAL,
            asistencia REAL,
            risk_score REAL,
            plataforma TEXT,
            intervenido INTEGER DEFAULT 0,
            docente_id TEXT
        )
    """))

    conn.execute(sa.text("""
        CREATE TABLE alerts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id TEXT,
            nombre TEXT,
            programa TEXT,
            nivel TEXT,
            motivo TEXT,
            fecha TEXT
        )
    """))

    conn.execute(sa.text("""
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            nombre TEXT,
            rol TEXT,
            programa TEXT
        )
    """))

    conn.execute(sa.text("""
        INSERT INTO students VALUES
        ('EST001','Ana García','Ingeniería','2026-1',3,2.8,61,82,'Baja',0,'DOC001'),
        ('EST002','Carlos López','Admón.','2026-1',5,3.4,75,55,'Media',0,'DOC002'),
        ('EST003','María Torres','Psicología','2026-1',2,4.1,92,20,'Alta',0,'DOC003'),
        ('EST004','Juan Martínez','Contaduría','2026-1',4,2.5,58,78,'Baja',0,'DOC001'),
        ('EST005','Laura Pérez','Ingeniería','2026-1',6,3.2,70,60,'Media',0,'DOC001'),
        ('EST006','Pedro Sánchez','Admón.','2026-1',1,4.5,95,15,'Alta',0,'DOC002'),
        ('EST007','Sofía Ramírez','Psicología','2026-1',3,2.3,55,85,'Baja',0,'DOC003'),
        ('EST008','Andrés Castro','Contaduría','2026-1',5,3.6,78,50,'Media',0,'DOC002')
    """))

    conn.execute(sa.text("""
        INSERT INTO alerts VALUES
        (1,'EST001','Ana García','Ingeniería','Alto','Notas bajas y baja asistencia','2026-1-10'),
        (2,'EST004','Juan Martínez','Contaduría','Alto','Asistencia crítica','2026-1-10'),
        (3,'EST007','Sofía Ramírez','Psicología','Alto','Múltiples factores de riesgo','2026-1-10'),
        (4,'EST002','Carlos López','Admón.','Medio','Bajo rendimiento académico','2026-1-10'),
        (5,'EST005','Laura Pérez','Ingeniería','Medio','Asistencia irregular','2026-1-10')
    """))

    conn.execute(sa.text("""
        INSERT INTO users VALUES
        (1,'admin','admin123','Administrador del Sistema','admin',NULL),
        (2,'coordinador','coord123','María Coordinadora','coordinador',NULL),
        (3,'docente1','doc123','Carlos Docente','docente','Ingeniería'),
        (4,'docente2','doc123','Laura Docente','docente','Admón.'),
        (5,'docente3','doc123','Pedro Docente','docente','Psicología')
    """))

    conn.commit()
    print("Base de datos creada correctamente")