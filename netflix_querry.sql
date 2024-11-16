-- 1. Count the number of Movies vs TV Shows
select type ,count(*) as total_content from netflix_titles group by type;

-- 2. Find the most common rating for movies and TV shows
with ratingcount as 
(select type,rating,count(*) as rating_count from netflix_titles group by type,rating) ,
rankedrating as
(select type,rating,rating_count,rank() over(partition by type order by rating_count desc) as ranking from ratingcount)
select type, rating as most_frequent_rating from rankedrating where ranking=1;


-- 3. List all movies released in a specific year (e.g., 2020) and country according to your choice
select* from netflix_titles where release_year = 2000;
SELECT type,release_year,title,country
FROM netflix_titles
WHERE release_year  = 1998 and country="India"   group by type,release_year,title;


-- 4. Find the top 5 countries with the most content on Netflix
select country ,count(show_id) as number_of_shows from netflix_titles group by country order by number_of_shows desc limit 5  ;

-- or another way

WITH RECURSIVE country_split AS (
    -- Base case: Extract the first country from the string
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country,
        SUBSTRING_INDEX(country, ',', -1) AS remaining,
        CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) AS delim_count
    FROM netflix_titles

    UNION ALL

    -- Recursive case: Extract the next country from the remaining string
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS country,
        SUBSTRING_INDEX(remaining, ',', -1) AS remaining,
        delim_count - 1
    FROM country_split
    WHERE delim_count > 0
)

-- Final query: Count occurrences of each country and filter the top 5
SELECT 
    country,
    COUNT(*) AS total_content
FROM 
    country_split
WHERE 
    country IS NOT NULL
GROUP BY 
    country
ORDER BY 
    total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

select *from netflix_titles where type="movie" and  duration=(select max(duration) from netflix_titles ) ;


-- 6. Find content added in the last 5 years
SELECT 
    *
FROM 
    netflix_titles 
WHERE 
    STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;
    
    
    -- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix_titles
WHERE director LIKE "%Theodore Melfi%";




-- 8. List all TV shows with more than 5 seasons

select *from netflix_titles where type="TV show" and duration > 3 order by duration asc;
select * from netflix_titles where type="TV Show";



-- 9. Count the number of content items in each genre
WITH RECURSIVE genre_split AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING_INDEX(listed_in, ',', -1) AS remaining,
        CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) AS delim_count
    FROM netflix_titles
    UNION ALL
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS genre,
        SUBSTRING_INDEX(remaining, ',', -1) AS remaining,
        delim_count - 1
    FROM genre_split
    WHERE delim_count > 0
)
SELECT 
    genre,
    COUNT(*) AS total_content
FROM 
    genre_split
WHERE 
    genre IS NOT NULL
GROUP BY 
    genre
ORDER BY 
    total_content DESC;
    
    
-- 10. Find each year and the average numbers of content release by India on netflix.  !

SELECT 
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year, 
    COUNT(*) AS total_titles
FROM 
    netflix_titles
WHERE 
    country = "India"
GROUP BY 
    year;
    
    
-- 11 count the content item  in each genere

WITH RECURSIVE genre_split AS (SELECT show_id,TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING_INDEX(listed_in, ',', -1) AS remaining,
        CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) AS delim_count
    FROM netflix_titles
    UNION ALL
    SELECT show_id,TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS genre,
        SUBSTRING_INDEX(remaining, ',', -1) AS remaining,
        delim_count - 1
    FROM genre_split
    WHERE delim_count > 0
)
SELECT genre,COUNT(*) AS total_content FROM genre_split GROUP BY genre ORDER BY  total_content DESC;



-- 11. List all movies that are documentaries
select *from netflix_titles where listed_in like"%Documentaries%"
-- 12. Find all content without a director
SELECT * FROM netflix_title
WHERE director IS NULL