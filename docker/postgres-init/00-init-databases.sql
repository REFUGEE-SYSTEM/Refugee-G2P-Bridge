SELECT 'CREATE DATABASE examplebankdb'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'examplebankdb')\gexec
