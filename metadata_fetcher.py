import polars as pl
import requests
import os
import io
import csv
from dotenv import load_dotenv

url = "https://www.gmonads.com/api/v1/public/validators/metadata?network=mainnet"

# Extract Validator Metadata from Gmonads API

response = requests.get(url, headers={'accept': 'application/json'})
val = pl.read_json(io.BytesIO(response.content))
result = val.select(pl.col("data").explode()).unnest("data")
df = pl.DataFrame(result)
new = df.select("id", "name", "website")
buffer = io.StringIO()
writer = csv.writer(buffer, quoting=csv.QUOTE_ALL) 
writer.writerow(["id", "name", "website"])
for row in new.iter_rows():
    writer.writerow(row)

data = buffer.getvalue()

# load environment
load_dotenv()

namespace = os.getenv("namespace")
table_name = "monad_validator_metadata"
api_key = os.getenv("X-DUNE-API-KEY")

# Clear Table and Input Up-to-date Validator Metadata
input_url = f"https://api.dune.com/api/v1/uploads/{namespace}/{table_name}/insert"
clear_url = f"https://api.dune.com/api/v1/uploads/{namespace}/{table_name}/clear"

headers = {
    "X-DUNE-API-KEY": api_key,
    "Content-Type": "text/csv"
}

lines = data.splitlines()
print(f"Total lines (incl. header): {len(lines)}")
if len(lines) >= 222:
    print(f"Line 222: {lines[221]}")


clear = requests.post(clear_url, params={"api_key": api_key})
print(clear.status_code)
print(clear.text)
input = requests.request("POST", input_url, data=data, headers=headers)
print(input.status_code)
print(input.text)
