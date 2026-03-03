
from sqlalchemy import Column, String, Integer, Float, DateTime, JSON, Text, ForeignKey
from sqlalchemy.orm import relationship
from .db import Base

class Student(Base):
    __tablename__ = "students"
    student_id = Column(String(50), primary_key=True)
    nombre = Column(String(120), nullable=False)
    programa = Column(String(100))
    cohorte = Column(String(20))
    modalidad = Column(String(50))
    campus = Column(String(50))
    estado = Column(String(20), default="activo")

class RiskScore(Base):
    __tablename__ = "risk_scores"
    id = Column(Integer, primary_key=True, autoincrement=True)
    student_id = Column(String(50), ForeignKey("students.student_id"))
    periodo = Column(String(20))
    score = Column(Float)
    nivel = Column(String(10))
    prioridad = Column(Float)
    razones_json = Column(JSON)
    model_version = Column(String(50))
    scored_at = Column(DateTime)
