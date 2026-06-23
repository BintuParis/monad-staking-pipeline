# Monad Stake Delegation Data Ingestion Pipeline

This repository contains the indexing and ETL configuration pipeline to extract raw onchain event logs related to the **Monad Validator Delegations**. 

The pipeline filters raw EVM logs from the Monad network and routes them to a structured relational database for downstream quantitative analysis.

## Pipeline Architecture

- **Source:** `monad.raw_logs` 
- **Target System contract:** `0x0000000000000000000000000000000000001000` (Monad Staking Precompile)
- **Sink:** Postgres Database (`monad_vdp_raw`)
