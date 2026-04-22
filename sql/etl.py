# %%
import pandas as pd
import sqlalchemy

engine = sqlalchemy.create_engine(
    "sqlite:///C:/Workspace/UsersPerfilCompornamental/data/database.db"
)

with open("etl.sql") as open_file:
    query = open_file.read()

# %%
dates = [
    '2025-01-01',
    '2025-02-01',
    '2025-03-01',
    '2025-04-01',
    '2025-05-01',
    '2025-06-01',
    '2025-07-01',
]

for i in dates:
    df = pd.read_sql(query.format(date=i), engine)

    df.to_sql("feature_store_cliente", engine, index=False, if_exists="append")
# %%
