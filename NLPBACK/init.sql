-- Create the postgres role if it doesn't exist
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'nlp') THEN
      CREATE ROLE nlp WITH LOGIN SUPERUSER PASSWORD 'postgres';
   END IF;
END
$$;

-- The database stem_careers is already created by Docker Compose
-- No need to create it again

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE stem_careers TO nlp;
