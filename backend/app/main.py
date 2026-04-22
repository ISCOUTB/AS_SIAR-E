
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes_students import router as students_router
from app.api.routes_risk import router as risk_router
from app.api.routes_dashboard import router as dashboard_router


def create_app() -> FastAPI:
    app = FastAPI(title="Alertas Tempranas - API (MySQL)")
    # Habilitar CORS para desarrollo del frontend (ajustar en producción)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(students_router, prefix="/students", tags=["students"])
    app.include_router(risk_router, prefix="/risk", tags=["risk"])
    app.include_router(dashboard_router, prefix="/dashboard", tags=["dashboard"])
    return app


app = create_app()
