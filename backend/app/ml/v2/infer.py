
__version__ = "v2"

from app.ml.common import score_batch_shared, explain_rows_shared


def score_batch(df):
    return score_batch_shared(df)


def explain_rows(df):
    return explain_rows_shared(df)
