
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db import get_session

router = APIRouter()

@router.get("")
def list_students(limit: int = 50, offset: int = 0, db: Session = Depends(get_session)):
    rows = db.execute(
        text("SELECT student_id, nombre, programa, cohorte FROM students LIMIT :lim OFFSET :off"),
        {"lim": limit, "off": offset}
    ).mappings().all()
    return list(rows)

@router.get("/{student_id}")
def get_student(student_id: str, db: Session = Depends(get_session)):
    row = db.execute(text("SELECT * FROM students WHERE student_id=:sid"), {"sid": student_id}).mappings().first()
    return row or {}
