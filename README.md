
# Early Alerts (Backend FastAPI + MySQL)

MVP del **backend** para un sistema de **alertas tempranas** con:
- FastAPI + SQLAlchemy (MySQL)
- Rutas separadas (`/students`, `/risk`)
- **Versionado de modelos** bajo `app/ml/v*/` y un **registry** para activar la versión
- **Tests** (pytest) y un **infer v1** basado en reglas (sin artefactos ML) para funcionar desde el inicio
- `docker-compose` para levantar **MySQL** + **API**

> Nota: Este MVP usa un **modelo v1 rule-based** para calcular scores sin necesidad de `model.pkl`. Puedes crear `v2` o reemplazar v1 por un modelo real cuando entrenes y guardes artefactos.

## Requisitos
- Docker + Docker Compose
- Python 3.11 (opcional, solo si corres tests localmente)

## Arranque rápido con Docker
```bash
# Desde la carpeta del repo
docker compose up --build
```
- API Docs: http://localhost:8000/docs
- MySQL: `localhost:3306` (user: `app`, pass: `app123`, db: `alerts`)

La base se inicializa con `infra/sql/schema_mysql.sql` y `infra/sql/seed.sql` (2 estudiantes + features).

## Endpoints clave
- `GET /students` — listar estudiantes
- `GET /students/{student_id}` — detalle
- `POST /risk/predict` — genera/recalcula scores de un período (usa la versión activa del modelo)
- `GET /risk/alerts/{periodo}` — top alertas por prioridad/score

### Ejemplos
```bash
# Predicción (scoring)
curl -X POST http://localhost:8000/risk/predict   -H 'Content-Type: application/json'   -d '{"periodo":"2025-1"}'

# Ver alertas
echo; curl http://localhost:8000/risk/alerts/2025-1 | jq .
```

## Tests
```bash
cd backend
pytest -q
```
Los tests usan **SQLite in-memory** automáticamente para no depender de MySQL.

## Versionado de modelos (registry)
- Edita `backend/app/ml/registry.json` para cambiar la versión activa (`v1`, `v2`, ...)
- Implementa cada versión en su carpeta (`app/ml/vX/infer.py`) con:
  - `__version__`
  - `score_batch(df: pd.DataFrame) -> pd.DataFrame`
  - `explain_rows(df: pd.DataFrame) -> list[dict]`

Si luego entrenas un modelo real, puedes cargar artefactos (p. ej., `joblib`) dentro de `v2/infer.py`.

## Variables de entorno
Ver `infra/env.example`. `docker-compose.yml` ya configura valores por defecto.

---

© 2026 Early Alerts MVP
