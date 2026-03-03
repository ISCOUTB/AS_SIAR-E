
def test_openapi_available(test_client):
    res = test_client.get('/openapi.json')
    assert res.status_code == 200
    assert 'openapi' in res.json()
