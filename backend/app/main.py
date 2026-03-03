
from fastapi import FastAPI
from app.api.routes_students import router as students_router
from app.api.routes_risk import router as risk_router

def create_app() -> FastAPI:
    app = FastAPI(title="Alertas Tempranas - API (MySQL)")
    app.include_router(students_router, prefix="/students", tags=["students"])
    app.include_router(risk_router, prefix="/risk", tags=["risk"])
    return app

app = create_app()
