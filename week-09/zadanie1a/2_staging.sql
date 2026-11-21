CREATE SCHEMA IF NOT EXISTS silver;

CREATE VIEW silver.stg_users AS
    SELECT TRIM(id)::INT AS user_id,
    TRIM(age)::INT AS age,
    UPPER(TRIM(gender)) AS gender,
    TRIM(occupation_id)::INT AS occupation_id,
    TRIM(zip_code) AS zip_code
    FROM bronze.users;

CREATE VIEW silver.stg_ratings AS
    SELECT TRIM(id)::INT AS rating_id,
    TRIM(user_id)::INT AS user_id,
    TRIM(movie_id)::INT AS movie_id,
    TRIM(rating)::INT AS rating,
    TRIM(rated_at)::TIMESTAMP AS rated_at
    FROM bronze.ratings;

CREATE VIEW silver.stg_occupations AS
    SELECT TRIM(id)::INT AS occupation_id,
    TRIM(name)::varchar(50) AS name
    FROM bronze.occupations;

CREATE VIEW silver.stg_movies AS
    SELECT TRIM(id)::INT AS movie_id,
    TRIM(title)::varchar(200) AS title,
    TRIM(release_year)::INT AS release_year
    FROM bronze.movies;

CREATE VIEW silver.stg_genres AS
    SELECT TRIM(id)::INT AS genre_id,
    TRIM(name)::varchar(50) AS name
    FROM bronze.genres;

CREATE VIEW silver.stg_genres_movies AS
    SELECT TRIM(id)::INT AS genre_movie_id,
    TRIM(movie_id)::INT AS movie_id,
    TRIM(genre_id)::INT AS genre_id
    FROM bronze.genres_movies;

CREATE VIEW silver.stg_age_group AS
    SELECT TRIM(id)::INT AS age_group_id,
    TRIM(name)::varchar(50) AS name
    FROM bronze.age_group;

SELECT * FROM silver.stg_age_group ORDER BY age_group_id LIMIT 100;