-- Active: 1790866429854@@127.0.0.1@5432@movielens_elt@bronze
-- Active: 1790866429854@@127.0.0.1@5432@movielens_elt@bronze-- Active: 1790866429854@@127.0.0.1@5432@postgres


--CREATE DATABASE movielens_elt;--
--CREATE SCHEMA IF NOT EXISTS bronze;--
CREATE TABLE IF NOT EXISTS bronze.users (
    id TEXT,
    age TEXT,
    gender TEXT,
    occupation_id TEXT,
    zip_code TEXT,
    _source_file TEXT DEFAULT 'users.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.ratings (
    id TEXT,
    user_id TEXT,
    movie_id TEXT,
    rating TEXT,
    rated_at TEXT,
    _source_file TEXT DEFAULT 'ratings.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.occupations (
    id TEXT,
    name TEXT,
    _source_file TEXT DEFAULT 'occupations.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.movies (
    id TEXT,
    title TEXT,
    release_year TEXT,
    _source_file TEXT DEFAULT 'movies.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.genres (
    id TEXT,
    name TEXT,
    _source_file TEXT DEFAULT 'genres.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.genres_movies (
    id TEXT,
    movie_id TEXT,
    genre_id TEXT,
    _source_file TEXT DEFAULT 'genres_movies.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.age_group (
    id TEXT,
    name TEXT,
    _source_file TEXT DEFAULT 'age_group.csv',
    _loaded_at TIMESTAMPTZ DEFAULT now()
);

\set ON_ERROR_STOP on
\encoding UTF8

BEGIN;
TRUNCATE bronze.users;
\COPY bronze.users (id, age, gender, occupation_id, zip_code) FROM 'csv/users.csv' WITH (FORMAT CSV, HEADER TRUE)
TRUNCATE bronze.ratings;
\COPY bronze.ratings (id, user_id, movie_id, rating, rated_at) FROM 'csv/ratings.csv' WITH (FORMAT CSV, HEADER TRUE)
TRUNCATE bronze.occupations;
\COPY bronze.occupations (id, name) FROM 'csv/occupations.csv' WITH (FORMAT CSV, HEADER TRUE)
TRUNCATE bronze.movies;
\COPY bronze.movies (id, title, release_year) FROM 'csv/movies.csv' WITH (FORMAT CSV, HEADER TRUE)
TRUNCATE bronze.genres;
\COPY bronze.genres (id, name) FROM 'csv/genres.csv' WITH (FORMAT CSV, HEADER TRUE)
TRUNCATE bronze.genres_movies;
\COPY bronze.genres_movies (id, movie_id, genre_id) FROM 'csv/genres_movies.csv' WITH (FORMAT CSV, HEADER TRUE)
TRUNCATE bronze.age_group;
\COPY bronze.age_group (id, name) FROM 'csv/age_group.csv' WITH (FORMAT CSV, HEADER TRUE)
COMMIT;

SELECT * FROM bronze.users LIMIT 10;