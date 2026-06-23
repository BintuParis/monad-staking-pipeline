import polars as pl
import requests
import os
import io
from dotenv import load_dotenv
import json
from dune_client.types import QueryParameter
from dune_client.client import DuneClient
from dune_client.query import QueryBase

load_dotenv()
dune = DuneClient.from_env()

query = QueryBase(
    query_id=7717567
)
results_csv = dune.run_query_csv(query)
df = pl.read_csv(
    results_csv.data,
    null_values=["<nil>"],
    infer_schema_length=10000,
)
df.write_csv("Vdp_dataset.csv")

