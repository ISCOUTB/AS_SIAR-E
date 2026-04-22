
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional, List, Dict, Annotated
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db import get_session
from app.ml_loader import get_active_infer_module

router = APIRouter()

class PredictRequest(BaseModel):
    periodo: str
    student_ids: Optional[List[str]] = None

class RiskScoreOut(BaseModel):
    student_id: str
    periodo: str
    score: float
    nivel: str
    prioridad: float
    razones: Dict[str, float]

@router.post("/predict", response_model=List[RiskScoreOut])
def predict(req: PredictRequest, db: Annotated[Session, Depends(get_session)]):
    infer = get_active_infer_module()
    df = fetch_features_df(db, req.periodo, req.student_ids)
    if df.empty:
        return []
    scored = infer.score_batch(df)
    razones = infer.explain_rows(df) if hasattr(infer, "explain_rows") else [{} for _ in range(len(scored))]
    save_scores(db, scored, razones, model_version=infer.__version__)
    result = []
    for (idx, r), razon in zip(scored.iterrows(), razones):
        result.append(
            RiskScoreOut(
                student_id=r["student_id"], periodo=r["periodo"],
                score=float(r["score"]), nivel=r["nivel"], prioridad=float(r["prioridad"]),
                razones=razon
            )
        )
    return result

@router.get("/alerts/{periodo}", response_model=List[RiskScoreOut])
def get_alerts(periodo: str, db: Annotated[Session, Depends(get_session)], limit: int = 200):
    rows = db.execute(text("""
        SELECT student_id, periodo, score, nivel, prioridad, razones_json
        FROM risk_scores WHERE periodo=:per
        ORDER BY prioridad DESC, score DESC
        LIMIT :lim
    """), {"per": periodo, "lim": limit}).mappings().all()
    import json
    return [
        RiskScoreOut(
            student_id=r["student_id"], periodo=r["periodo"], score=float(r["score"]),
            nivel=r["nivel"], prioridad=float(r["prioridad"]),
            razones=json.loads(r["razones_json"]) if r["razones_json"] else {}
        ) for r in rows
    ]

# Helpers

def fetch_features_df(db: Session, periodo: str, ids=None):
    import pandas as pd
    base = "SELECT * FROM features_estudiante_periodo WHERE periodo=:per"
    params = {"per": periodo}
    if ids:
        placeholders = ",".join([f":id{i}" for i in range(len(ids))])
        base += f" AND student_id IN ({placeholders})"
        params.update({f"id{i}": sid for i, sid in enumerate(ids)})
    rows = db.execute(text(base), params).mappings().all()
    return pd.DataFrame(rows)

def save_scores(db: Session, df_scored, razones_list, model_version: str):
    from sqlalchemy import text
    import json
    for (idx, row), razones in zip(df_scored.iterrows(), razones_list):
        db.execute(text("""
            INSERT INTO risk_scores (student_id, periodo, score, nivel, prioridad, razones_json, model_version, scored_at)
            VALUES (:sid, :per, :sc, :niv, :pri, CAST(:rz AS JSON), :mv, NOW())
        """), {
            "sid": row["student_id"], "per": row["periodo"], "sc": float(row["score"]),
            "niv": row["nivel"], "pri": float(row["prioridad"]),
            "rz": json.dumps(razones, ensure_ascii=False), "mv": model_version
        })
    db.commit()
