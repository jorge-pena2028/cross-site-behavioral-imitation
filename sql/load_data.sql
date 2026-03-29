-- =============================================================================
-- load_data.sql
-- Cross-Site Behavioral Imitation Analysis -- Data Import
--
-- Imports case_study_data.csv into the behavioral_data table.
-- Adjust the file path to match your environment before running.
-- =============================================================================

-- PostgreSQL: load from CSV using COPY
-- Update the path below to the absolute location of case_study_data.csv.

COPY behavioral_data (fieldsite, imitation, age)
FROM '/path/to/case_study_data.csv'
WITH (FORMAT csv, HEADER true);

-- Alternative for psql client (relative path supported):
-- \copy behavioral_data (fieldsite, imitation, age) FROM 'case_study_data.csv' WITH (FORMAT csv, HEADER true);

-- Verify row count after loading
SELECT COUNT(*) AS total_rows FROM behavioral_data;
SELECT fieldsite, COUNT(*) AS n FROM behavioral_data GROUP BY fieldsite ORDER BY fieldsite;
