# SQL Server Patient Tokenization Pipeline

This repository contains SQL scripts to tokenize patient records across multiple datasets (Open Claims, Closed Claims, Lab, EMR) and link them using SHA2_256 hashed tokens.

## Modules
- `01_create_token_map_table.sql`: Creates token storage table
- `02–06`: Tokenize individual datasets
- `07_build_token_master.sql`: Prioritize tokens across sources
- `08_link_open_claims_lab.sql`: Demonstrates patient linking example

## Notes
- Requires SQL Server 2016+ (for SHA2_256 support)
- Uses `HASHBYTES()` and `CONVERT()` for token creation
