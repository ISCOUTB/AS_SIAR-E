from fastapi import APIRouter, Depends
from typing import Annotated
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db import get_session

router = APIRouter()

@router.get("/alerts")
def get_dashboard_alerts(db: Annotated[Session, Depends(get_session)]):
    # Métricas generales
    total = db.execute(text("SELECT COUNT(*) as cnt FROM students")).mappings().first()['cnt']
    alto = db.execute(text("SELECT COUNT(*) as cnt FROM students WHERE risk_score >= 75")).mappings().first()['cnt']
    medio = db.execute(text("SELECT COUNT(*) as cnt FROM students WHERE risk_score >= 50 AND risk_score < 75")).mappings().first()['cnt']
    bajo = db.execute(text("SELECT COUNT(*) as cnt FROM students WHERE risk_score < 50")).mappings().first()['cnt']

    # Alertas recientes
    alertas = db.execute(text("""
        SELECT id, student_id, nombre, programa, nivel, motivo, fecha
        FROM alerts ORDER BY id DESC LIMIT 10
    """)).mappings().all()

    return {
        "metricas": {
            "total": total,
            "alto": alto,
            "medio": medio,
            "bajo": bajo
        },
        "alertas": [dict(a) for a in alertas]
        }

@router.get("/programs")
def get_programs_distribution(db: Annotated[Session, Depends(get_session)]):
    programas = db.execute(text("SELECT DISTINCT programa FROM students")).mappings().all()
    
    result = []
    for p in programas:
        prog = p['programa']
        alto = db.execute(text("SELECT COUNT(*) as cnt FROM students WHERE programa = :p AND risk_score >= 75"), {"p": prog}).mappings().first()['cnt']
        medio = db.execute(text("SELECT COUNT(*) as cnt FROM students WHERE programa = :p AND risk_score >= 50 AND risk_score < 75"), {"p": prog}).mappings().first()['cnt']
        bajo = db.execute(text("SELECT COUNT(*) as cnt FROM students WHERE programa = :p AND risk_score < 50"), {"p": prog}).mappings().first()['cnt']
        result.append({"programa": prog, "alto": alto, "medio": medio, "bajo": bajo})
    
    return result
    