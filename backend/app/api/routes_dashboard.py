from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from typing import List, Optional, Annotated
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db import get_session

router = APIRouter()


class DashboardStudent(BaseModel):
    id: str
    nombre: str
    programa: str
    semestre: Optional[str] = None
    riesgo: str
    score: float
    notas: Optional[float] = None
    asistencia: Optional[float] = None
    plataforma: Optional[str] = None
    intervenido: bool = False


@router.get("/alerts", response_model=List[DashboardStudent])
def get_dashboard_alerts(
    db: Annotated[Session, Depends(get_session)],
    periodo: str = Query(..., description="Periodo, p.ej. 2026-1"),
    limit: int = Query(100, ge=1),
):
    """Devuelve una lista compuesta para el dashboard con campos usados por la maqueta.
    Une `students`, `risk_scores` y `features_estudiante_periodo` para devolver
    las claves: id, nombre, programa, semestre, riesgo, score, notas, asistencia, plataforma, intervenido.
    """
    rows = db.execute(text("""
        SELECT s.student_id AS id, s.nombre, s.programa, s.cohorte,
               r.score, r.nivel, r.prioridad, f.prom_calif, f.pct_asistencia, f.dias_activo_lms
        FROM students s
        LEFT JOIN risk_scores r ON r.student_id = s.student_id AND r.periodo = :per
        LEFT JOIN features_estudiante_periodo f ON f.student_id = s.student_id AND f.periodo = :per
        ORDER BY r.prioridad DESC, r.score DESC
        LIMIT :lim
    """), {"per": periodo, "lim": limit}).mappings().all()

    def platform_label(days):
        if days is None:
            return "Desconocida"
        try:
            d = float(days)
        except Exception:
            return "Desconocida"
        if d >= 8:
            return "Alta"
        if d >= 4:
            return "Media"
        if d >= 1:
            return "Baja"
        return "Muy baja"

    result = []
    for r in rows:
        raw_score = r.get("score")
        score_pct = None
        if raw_score is not None:
            try:
                score_pct = float(raw_score) * 100.0
            except Exception:
                score_pct = 0.0

        nivel = r.get("nivel") or None
        if nivel:
            nivel_label = nivel.capitalize()
        else:
            # fallback según score
            if score_pct is None:
                nivel_label = "Desconocido"
            elif score_pct >= 70:
                nivel_label = "Alto"
            elif score_pct >= 30:
                nivel_label = "Medio"
            else:
                nivel_label = "Bajo"

        pct_asist = r.get("pct_asistencia")
        asistencia_val = None
        if pct_asist is not None:
            try:
                if float(pct_asist) <= 1.0:
                    asistencia_val = float(pct_asist) * 100.0
                else:
                    asistencia_val = float(pct_asist)
            except Exception:
                asistencia_val = None

        result.append(
            DashboardStudent(
                id=r.get("id") or "",
                nombre=r.get("nombre") or "",
                programa=r.get("programa") or "",
                semestre=str(r.get("cohorte")) if r.get("cohorte") is not None else None,
                riesgo=nivel_label,
                score=round(score_pct or 0.0, 0),
                notas=(float(r.get("prom_calif")) if r.get("prom_calif") is not None else None),
                asistencia=(round(asistencia_val, 1) if asistencia_val is not None else None),
                plataforma=platform_label(r.get("dias_activo_lms")),
                intervenido=False,
            )
        )

    return result
