DROP DATABASE IF EXISTS :"name";
CREATE DATABASE :"name" WITH ENCODING 'UTF8';
DROP USER IF EXISTS :"user";
CREATE USER :"user" WITH PASSWORD :'password';
ALTER DATABASE :"name" OWNER TO :"user";
ALTER SCHEMA public owner to :"user";
GRANT ALL PRIVILEGES ON DATABASE :"name" TO :"user";
GRANT USAGE ON SCHEMA public TO :"user";
GRANT CREATE ON SCHEMA public TO :"user";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO :"user";
\c :"name";
DROP TABLE IF EXISTS movie_ratings;
CREATE TABLE IF NOT EXISTS movie_ratings (
     window_start BIGINT NOT NULL,
     movie_id VARCHAR(32) NOT NULL,
     PRIMARY KEY (window_start, movie_id),
     title VARCHAR(128) NOT NULL,
     rating_count INTEGER NOT NULL,
     rating_sum INTEGER NOT NULL,
     unique_rating_count INTEGER NOT NULL
     
);
GRANT ALL PRIVILEGES ON TABLE movie_ratings TO :"user";
ALTER TABLE movie_ratings OWNER TO :"user";