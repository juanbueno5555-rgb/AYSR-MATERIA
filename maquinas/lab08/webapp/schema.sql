-- Lab 6, point 3: table for the grade calculator, in the PostgreSQL engine built in Lab 5.
-- Run as the database owner on the target database, for example:
--   psql -h 127.0.0.1 -p 5432 -U postgres -c "CREATE DATABASE notas_lab06 OWNER camilo;"
--   psql -h 127.0.0.1 -p 5432 -U camilo -d notas_lab06 -f schema.sql

CREATE TABLE IF NOT EXISTS notas (
  id          SERIAL PRIMARY KEY,
  estudiante  VARCHAR(100)  NOT NULL,
  nota1       NUMERIC(3,2)  NOT NULL CHECK (nota1 BETWEEN 0 AND 5),
  nota2       NUMERIC(3,2)  NOT NULL CHECK (nota2 BETWEEN 0 AND 5),
  nota3       NUMERIC(3,2)  NOT NULL CHECK (nota3 BETWEEN 0 AND 5),
  nota_final  NUMERIC(3,2)  NOT NULL CHECK (nota_final BETWEEN 0 AND 5),
  creado      TIMESTAMP     NOT NULL DEFAULT now()
);
