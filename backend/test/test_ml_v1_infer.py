
def test_v1_infer_contract():
    from app.ml.v1 import infer
    assert hasattr(infer, 'score_batch')
    assert hasattr(infer, 'explain_rows')
    assert infer.__version__ == 'v1'
