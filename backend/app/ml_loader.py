
import json
import importlib
from pathlib import Path

REG_PATH = Path(__file__).parent / "ml" / "registry.json"

def get_active_infer_module():
    registry = json.loads(REG_PATH.read_text(encoding="utf-8"))
    active = registry.get("active", "v1")
    mod_path = f"app.ml.{active}.infer"
    mod = importlib.import_module(mod_path)
    if not hasattr(mod, "__version__"):
        mod.__version__ = active
    return mod
