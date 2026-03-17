SELECT COUNT(*) AS total_perfumes
FROM perfumes;

--Gender distribution
SELECT
gender,
COUNT(*) perfumes
FROM perfumes
GROUP BY gender
ORDER BY perfumes DESC;

--Top brands
SELECT TOP 15
    brand,
    COUNT(*) AS perfumes
FROM perfumes
GROUP BY brand
ORDER BY perfumes DESC;

--Most common accords
SELECT
accord,
COUNT(*) frequency
FROM perfume_accords
GROUP BY accord
ORDER BY frequency DESC;

--Accord Popularity vs. User Sentiment
SELECT
pa.accord,
AVG(p.rating_value) AS avg_rating,
COUNT(*) AS perfume_count
FROM perfume_accords pa
JOIN perfumes p
ON pa.perfume_id = p.perfume_id
GROUP BY pa.accord
HAVING COUNT(*) > 40
ORDER BY avg_rating DESC;

--Bayesian Weighted Rating for Fragrance Accord Pairings
-- Step 1:
DECLARE @C FLOAT = (
    SELECT AVG(CAST(rating_value AS FLOAT))
    FROM perfumes
    WHERE rating_value IS NOT NULL
);

DECLARE @m FLOAT = (
    SELECT TOP 1 PERCENTILE_CONT(0.9)
    WITHIN GROUP (ORDER BY rating_count) OVER()
    FROM perfumes
    WHERE rating_count IS NOT NULL
);

-- Step 2:
WITH AccordPairs AS (
    SELECT 
        pa1.perfume_id,
        pa1.accord AS accord_1,
        pa2.accord AS accord_2
    FROM perfume_accords pa1
    JOIN perfume_accords pa2
        ON pa1.perfume_id = pa2.perfume_id
        AND pa1.accord < pa2.accord
),

-- Step 3:
PairStats AS (
    SELECT
        ap.accord_1,
        ap.accord_2,
        COUNT(p.perfume_id) AS total_perfumes,
        SUM(p.rating_value * p.rating_count) / SUM(p.rating_count) AS avg_rating,
        SUM(p.rating_count) AS total_votes
    FROM AccordPairs ap
    JOIN perfumes p
        ON ap.perfume_id = p.perfume_id
    WHERE p.rating_value IS NOT NULL
      AND p.rating_count IS NOT NULL
    GROUP BY ap.accord_1, ap.accord_2
)

-- Step 4:
SELECT TOP 30
    accord_1 + ' & ' + accord_2 AS accord_combination,
    total_perfumes,
    ROUND(avg_rating, 2) AS raw_avg_rating,
    ROUND(
        (CAST(total_votes AS FLOAT) / (total_votes + @m)) * avg_rating +
        (@m / (CAST(total_votes AS FLOAT) + @m)) * @C
    , 2) AS weighted_rating
FROM PairStats
WHERE total_perfumes > 15
ORDER BY weighted_rating DESC;

--Verified Top 20 Fragrance
-- Step 1: Calculate Global Mean (C)
DECLARE @C FLOAT = (
    SELECT AVG(CAST(rating_value AS FLOAT)) 
    FROM perfumes 
    WHERE rating_value IS NOT NULL
);

-- Step 2: Determine Vote Threshold (m) at 90th Percentile
DECLARE @m FLOAT = (
    SELECT TOP 1 PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY rating_count) OVER() 
    FROM perfumes 
    WHERE rating_count IS NOT NULL
);

-- Step 3: Apply Weighted Rating Formula
SELECT TOP 20
perfume_id,
    perfume,  
    brand,
    rating_value AS R,
    rating_count AS v,
    ROUND(
        ( (CAST(rating_count AS FLOAT) / (CAST(rating_count AS FLOAT) + @m)) * rating_value ) + 
        ( (@m / (CAST(rating_count AS FLOAT) + @m)) * @C )
    , 2) AS weighted_rating
FROM perfumes
WHERE rating_count IS NOT NULL
ORDER BY weighted_rating DESC;

-------
/* 1) Drop existing object if it exists */
IF OBJECT_ID('dbo.perfume_weighted', 'V') IS NOT NULL
    DROP VIEW dbo.perfume_weighted;
IF OBJECT_ID('dbo.perfume_weighted', 'U') IS NOT NULL
    DROP TABLE dbo.perfume_weighted;

/* 2) Final BI-Ready View: Weighted Perfume Ratings */
CREATE VIEW dbo.perfume_weighted
AS
SELECT
    p.perfume_id,
    p.perfume,
    p.brand,
    p.gender,
    p.rating_value,
    p.rating_count,
    ROUND(
        (
            (CAST(p.rating_count AS FLOAT) /
                (CAST(p.rating_count AS FLOAT) + s.m)
            ) * p.rating_value
        )
        +
        (
            (s.m /
                (CAST(p.rating_count AS FLOAT) + s.m)
            ) * s.C
        )
    ,2) AS weighted_rating
FROM perfumes p
CROSS JOIN (
    SELECT
        AVG(CAST(rating_value AS FLOAT)) AS C,
        MAX(p90) AS m
    FROM (
        SELECT
            PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY rating_count) OVER() AS p90,
            rating_value
        FROM perfumes
        WHERE rating_value IS NOT NULL
          AND rating_count IS NOT NULL
    ) t
) s
WHERE p.rating_value IS NOT NULL
  AND p.rating_count IS NOT NULL;