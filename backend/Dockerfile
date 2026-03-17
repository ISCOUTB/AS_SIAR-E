FROM python:3.11-slim
ENV PYTHONUNBUFFERED=1

# Crear usuario sin privilegios
RUN addgroup --system appuser && adduser --system --ingroup appuser appuser

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app

# Asegurar permisos y ejecutar como usuario no-root
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]