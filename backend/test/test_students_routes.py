
def test_list_students_ok(test_client):
    res = test_client.get('/students?limit=5')
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert any(d.get('student_id') == 'T001' for d in data)
