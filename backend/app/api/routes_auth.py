from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db import get_session
from typing import Annotated
from pydantic import BaseModel

router = APIRouter()

class LoginRequest(BaseModel):
    username: str
    password: str

@router.post("/login")
def login(request: LoginRequest, db: Annotated[Session, Depends(get_session)]):
    user = db.execute(
        text("SELECT * FROM users WHERE username = :u AND password = :p"),
        {"u": request.username, "p": request.password}
    ).mappings().first()

    if not user:
        return {"success": False, "message": "Usuario o contraseña incorrectos"}

    return {
        "success": True,
        "user": {
            "id": user["id"],
            "username": user["username"],
            "nombre": user["nombre"],
            "rol": user["rol"],
            "programa": user["programa"]
        }
    }