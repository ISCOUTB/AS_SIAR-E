"""Funciones y constantes comunes para inferencia ML (v1, v2).
Extrae la lógica compartida para reducir duplicación.
"""
__all__ = [
    "__version__",
    "FEATURES",
    "score_batch_shared",
    "explain_rows_shared",
]

__version__ = "common"

import numpy as np
import pandas as pd

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


def _compute_components(X: pd.DataFrame):
    # X is df[FEATURES]
    comps = {}
    comps["low_att"] = _clip01(1 - X["pct_asistencia"].fillna(0.0))
    comps["inactivity"] = _clip01(X["dias_desde_ultima_actividad"].fillna(30) / 30)
    comps["low_lms"] = _clip01(1 - (X["dias_activo_lms"].fillna(0) / 10))
    comps["late"] = _clip01(X["entregas_tarde"].fillna(0) / 5)
    comps["low_grades"] = _clip01((3.5 - X["prom_calif"].fillna(3.5)) / 2)
    comps["repro"] = _clip01(X["reprobaciones"].fillna(0) / 3)
    comps["financial"] = _clip01(X["dias_mora_prom"].fillna(0) / 30)
    comps["recency_int"] = _clip01(X["intervenciones_previas"].fillna(0) / 3)
    comps["credits"] = _clip01(X["creditos_en_curso"].fillna(0) / 20)
    return comps


def score_batch_shared(df: pd.DataFrame) -> pd.DataFrame:
    X = df[FEATURES].copy()
    comps = _compute_components(X)

    # mantener los pesos originales para compatibilidad
    risk = (
        0.25 * comps["low_att"] +
        0.20 * comps["inactivity"] +
        0.15 * comps["low_lms"] +
        0.10 * comps["late"] +
        0.20 * comps["low_grades"] +
        0.05 * comps["repro"] +
        0.05 * comps["financial"]
    )

    prioridad = 0.6 * risk + 0.2 * (1 - comps["inactivity"]) + 0.1 * comps["credits"] + 0.1 * comps["recency_int"]

    out = df[["student_id", "periodo"]].copy()
    out["score"] = risk.values.astype(float)
    out["nivel"] = [_to_level(p) for p in out["score"].values]
    out["prioridad"] = prioridad.values.astype(float)
    return out


def explain_rows_shared(df: pd.DataFrame):
    X = df[FEATURES].copy()
    comps = _compute_components(X)

    weights = {
        "Baja asistencia": 0.25,
        "Inactividad": 0.20,
        "Bajo uso LMS": 0.15,
        "Entregas tardías": 0.10,
        "Bajo promedio": 0.20,
        "Reprobaciones": 0.05,
        "Riesgo financiero": 0.05,
    }

    comps_list = [
        comps["low_att"], comps["inactivity"], comps["low_lms"], comps["late"],
        comps["low_grades"], comps["repro"], comps["financial"],
    ]
    names = list(weights.keys())

    reasons = []
    matrix = np.vstack([c.values for c in comps_list]).T  # n x k
    weights_values = list(weights.values())
    for vals in matrix:
        contribs = {names[i]: float(vals[i] * weights_values[i]) for i in range(len(names))}
        top = dict(sorted(contribs.items(), key=lambda x: x[1], reverse=True)[:5])
        reasons.append(top)
    return reasons
