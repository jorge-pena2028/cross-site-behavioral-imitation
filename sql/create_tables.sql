-- =============================================================================
-- create_tables.sql
-- Cross-Site Behavioral Imitation Analysis -- Database Schema
--
-- Creates a single table for the behavioral imitation dataset containing
-- observations from 4 international field sites.
--
-- Compatible with PostgreSQL.
-- =============================================================================

DROP TABLE IF EXISTS behavioral_data;

CREATE TABLE behavioral_data (
    id SERIAL PRIMARY KEY,
    fieldsite VARCHAR(20) NOT NULL,
    imitation NUMERIC(4,1) NOT NULL,
    age NUMERIC(4,1) NOT NULL
);
