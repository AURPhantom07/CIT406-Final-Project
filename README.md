## How to Rebuild the Database

This repository provides two ways to rebuild the Athletics Management System database.

### Option 1: One-Click Setup (Recommended for quick testing)
The `full_setup/FullProject.sql` file contains the entire database script in one document. Running this single file will drop any existing tables, build the schema, insert all seed data, and create the views, triggers, and functions all at once. 

### Option 2: Modular Setup (Recommended for developers)
If you want to run the database in stages or modify the individual components, use the files in the `modular_setup/` folder. Run them in this exact numerical order:
1. `01_schema.sql` (Creates tables and constraints)
2. `02_seed.sql` (Inserts sample data)
3. `03_objects.sql` (Creates views, functions, triggers, and transactions)
4. `04_security.sql` (Creates roles and Row-Level Security)