
# AS_SIAR-E

Backend Python (FastAPI) para gestión de estudiantes y predicción de riesgo. Expone APIs REST y sirve inferencias de modelos ML versionados.

Descripción
- Proyecto orientado a alertas tempranas: gestión de estudiantes y predicción de riesgo académico.

Estructura clave
- `backend/app`: código de la API y carga de modelos.
- `backend/app/api`: rutas (`routes_students.py`, `routes_risk.py`).
- `backend/app/ml`: modelos versionados y `registry.json` (p.ej. `v1`, `v2`).
- `test/`: pruebas con `pytest`.

Inicio rápido
1. En el directorio raíz del proyecto:

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Levantar la API (desde `backend`):

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Pruebas

```bash
pytest -q
```

Endpoints principales
- `/health` — estado del servicio.
- `/students` — gestión de estudiantes (ver [backend/app/api/routes_students.py](backend/app/api/routes_students.py)).
- `/risk` — cálculo/consulta de riesgo (ver [backend/app/api/routes_risk.py](backend/app/api/routes_risk.py)).

Inferencia ML
- Modelos versionados en `backend/app/ml/v1` y `backend/app/ml/v2`.
- El registro de versiones está en `backend/app/ml/registry.json` y la carga la hace `backend/app/ml_loader.py`.

Contribuir
- Pull requests bienvenidos. Sigue las pruebas antes de proponer cambios.



