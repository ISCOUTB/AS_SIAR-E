# Estructura por capas

Descripción breve de la arquitectura por capas aplicada en este repositorio.

```mermaid
graph LR
  subgraph API[Presentación / API]
    A[routes_students.py]
    B[routes_risk.py]
  end

  subgraph App[Aplicación / Orquestación]
    C[main.py]
    D[ml_loader.py]
  end

  subgraph Domain[Dominio / Modelos]
    E[models.py]
  end

  subgraph Infra[Persistencia / Infraestructura]
    F[db.py]
    G[Dockerfile]
  end

  subgraph ML[Servicios ML]
    H[ml/common.py]
    I[ml/v1/infer.py]
    J[ml/v2/infer.py]
    K[ml/registry.json]
  end

  subgraph Tests[Pruebas]
    L[test/]
  end

  A --> C
  B --> C
  C --> E
  E --> F
  C --> H
  H --> I
  H --> J
  Tests --> C
```

Mapping de responsabilidades (archivos clave):

- **Presentación / API:** [backend/app/api/routes_students.py](backend/app/api/routes_students.py), [backend/app/api/routes_risk.py](backend/app/api/routes_risk.py)
- **Aplicación / Orquestación:** [backend/app/main.py](backend/app/main.py), [backend/app/ml_loader.py](backend/app/ml_loader.py)
- **Dominio / Modelos:** [backend/app/models.py](backend/app/models.py)
- **Persistencia / Infraestructura:** [backend/app/db.py](backend/app/db.py), [backend/Dockerfile](backend/Dockerfile)
- **Servicios ML:** [backend/app/ml/common.py](backend/app/ml/common.py), [backend/app/ml/v1/infer.py](backend/app/ml/v1/infer.py), [backend/app/ml/v2/infer.py](backend/app/ml/v2/infer.py), [backend/app/ml/registry.json](backend/app/ml/registry.json)
- **Pruebas:** carpeta [test/](test/)

Notas:

- Si quieres, puedo generar una imagen PNG del diagrama Mermaid y añadirla aquí.
- También puedo anotar funciones específicas dentro de cada archivo si necesitas responsabilidades más finas.
