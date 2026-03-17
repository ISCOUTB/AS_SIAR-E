
__version__ = "v1"

import pandas as pd
import numpy as np

FEATURES = [
    "prom_calif",
    "reprobaciones",
    "pct_asistencia",
    "dias_activo_lms",
    "entregas_tarde",
    "dias_desde_ultima_actividad",
    "dias_mora_prom",
    "intervenciones_previas",
    "creditos_en_curso",
]

def _clip01(x):
    return np.clip(x, 0.0, 1.0)

def _to_level(p, p70=0.3, p90=0.6):
    if p >= p90:
        return "ALTO"
    if p >= p70:
        return "MEDIO"
    return "BAJO"

# Regla heurística: combina señales de riesgo en [0,1]

def score_batch(df: pd.DataFrame) -> pd.DataFrame:
    X = df[FEATURES].copy()
    # Componentes de riesgo (normalizados)
    low_att = _clip01(1 - X["pct_asistencia"].fillna(0.0))
    inactivity = _clip01(X["dias_desde_ultima_actividad"].fillna(30) / 30)
    low_lms = _clip01(1 - (X["dias_activo_lms"].fillna(0) / 10))
    late = _clip01(X["entregas_tarde"].fillna(0) / 5)
    low_grades = _clip01((3.5 - X["prom_calif"].fillna(3.5)) / 2)
    repro = _clip01(X["reprobaciones"].fillna(0) / 3)
    financial = _clip01(X["dias_mora_prom"].fillna(0) / 30)
    recency_int = _clip01(X["intervenciones_previas"].fillna(0) / 3)
    credits = _clip01(X["creditos_en_curso"].fillna(0) / 20)

    risk = (
        0.25 * low_att +
        0.20 * inactivity +
        0.15 * low_lms +
        0.10 * late +
        0.20 * low_grades +
        0.05 * repro +
        0.05 * financial
    )

    prioridad = 0.6 * risk + 0.2 * (1 - inactivity) + 0.1 * credits + 0.1 * recency_int

    out = df[["student_id", "periodo"]].copy()
    out["score"] = risk.values.astype(float)
    out["nivel"] = [ _to_level(p) for p in out["score"].values ]
    out["prioridad"] = prioridad.values.astype(float)
    return out

# Explicación: devolvemos principales contribuciones heurísticas

def explain_rows(df: pd.DataFrame):
    X = df[FEATURES].copy()
    low_att = _clip01(1 - X["pct_asistencia"].fillna(0.0))
    inactivity = _clip01(X["dias_desde_ultima_actividad"].fillna(30) / 30)
    low_lms = _clip01(1 - (X["dias_activo_lms"].fillna(0) / 10))
    late = _clip01(X["entregas_tarde"].fillna(0) / 5)
    low_grades = _clip01((3.5 - X["prom_calif"].fillna(3.5)) / 2)
    repro = _clip01(X["reprobaciones"].fillna(0) / 3)
    financial = _clip01(X["dias_mora_prom"].fillna(0) / 30)

    weights = {
        "Baja asistencia": 0.25,
        "Inactividad": 0.20,
        "Bajo uso LMS": 0.15,
        "Entregas tardías": 0.10,
        "Bajo promedio": 0.20,
        "Reprobaciones": 0.05,
        "Riesgo financiero": 0.05
    }

    comps = [low_att, inactivity, low_lms, late, low_grades, repro, financial]
    names = list(weights.keys())

    reasons = []
    import numpy as np
    matrix = np.vstack([c.values for c in comps]).T  # n x k
    weights_values = list(weights.values())
    for vals in matrix:
        contribs = {names[i]: float(vals[i] * weights_values[i]) for i in range(len(names))}
        # Top 5 contribuciones absolutas
        top = dict(sorted(contribs.items(), key=lambda x: x[1], reverse=True)[:5])
        reasons.append(top)
    return reasons
