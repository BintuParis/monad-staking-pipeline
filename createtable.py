import requests
import os
from dotenv import load_dotenv

load_dotenv()

url = "https://api.dune.com/api/v1/uploads"

payload = {
    "namespace": os.getenv("namespace"),
    "table_name": "monad_validator_metadata",
    "description": "Monad Validator metadata sourced from https://gmonads.com",
    "schema": [{"name": "id", "type": "integer"}, {"name": "name", "type": "varchar", "nullable": True}, {"name": "website", "type": "varchar"}],
    "is_private": False
}

headers = {
    "X-DUNE-API-KEY": os.getenv("X-DUNE-API-KEY"),
    "Content-Type": "application/json"
}


response = requests.request("POST", url, json=payload, headers=headers)
print(response.status_code)