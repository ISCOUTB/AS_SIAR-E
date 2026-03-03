
from app.api import routes_risk

def test_predict_empty_when_no_features(test_client, monkeypatch):
    import pandas as pd
    def fake_fetch(db, periodo, ids=None):
        return pd.DataFrame()
    monkeypatch.setattr(routes_risk, 'fetch_features_df', fake_fetch)
    res = test_client.post('/risk/predict', json={"periodo":"2025-1"})
    assert res.status_code == 200
    assert res.json() == []
