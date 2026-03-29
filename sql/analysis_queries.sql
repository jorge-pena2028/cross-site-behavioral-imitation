-- =============================================================================
-- analysis_queries.sql
-- Cross-Site Behavioral Imitation Analysis -- Analytical Queries
--
-- SQL analytical queries for the behavioral imitation dataset.
-- All queries reference the behavioral_data table.
--
-- Compatible with PostgreSQL.
-- =============================================================================


-- -------------------------------------------------------------------------
-- 1. Descriptive statistics by Fieldsite
-- -------------------------------------------------------------------------
SELECT
    fieldsite,
    COUNT(*)                          AS n,
    ROUND(AVG(imitation), 2)          AS mean_imitation,
    ROUND(STDDEV(imitation), 2)       AS sd_imitation,
    ROUND(AVG(age), 2)                AS mean_age,
    ROUND(STDDEV(age), 2)             AS sd_age
FROM behavioral_data
GROUP BY fieldsite
ORDER BY fieldsite;


-- -------------------------------------------------------------------------
-- 2. 95% confidence interval estimation for Imitation by Fieldsite
-- -------------------------------------------------------------------------
SELECT
    fieldsite,
    COUNT(*)                                                      AS n,
    ROUND(AVG(imitation), 2)                                      AS mean_imitation,
    ROUND(STDDEV(imitation), 2)                                   AS sd_imitation,
    ROUND(AVG(imitation) - 1.96 * STDDEV(imitation) / SQRT(COUNT(*)), 2) AS ci_lower,
    ROUND(AVG(imitation) + 1.96 * STDDEV(imitation) / SQRT(COUNT(*)), 2) AS ci_upper
FROM behavioral_data
GROUP BY fieldsite
ORDER BY mean_imitation DESC;


-- -------------------------------------------------------------------------
-- 3. Cross-site comparison: pivoted summary
-- -------------------------------------------------------------------------
SELECT
    'Imitation' AS metric,
    ROUND(AVG(CASE WHEN fieldsite = 'USA'       THEN imitation END), 2) AS usa,
    ROUND(AVG(CASE WHEN fieldsite = 'Mexico'    THEN imitation END), 2) AS mexico,
    ROUND(AVG(CASE WHEN fieldsite = 'Japan'     THEN imitation END), 2) AS japan,
    ROUND(AVG(CASE WHEN fieldsite = 'Australia' THEN imitation END), 2) AS australia
FROM behavioral_data

UNION ALL

SELECT
    'Age' AS metric,
    ROUND(AVG(CASE WHEN fieldsite = 'USA'       THEN age END), 2) AS usa,
    ROUND(AVG(CASE WHEN fieldsite = 'Mexico'    THEN age END), 2) AS mexico,
    ROUND(AVG(CASE WHEN fieldsite = 'Japan'     THEN age END), 2) AS japan,
    ROUND(AVG(CASE WHEN fieldsite = 'Australia' THEN age END), 2) AS australia
FROM behavioral_data;


-- -------------------------------------------------------------------------
-- 4. Age vs Imitation correlation (Pearson formula in SQL)
-- -------------------------------------------------------------------------
SELECT
    fieldsite,
    COUNT(*) AS n,
    ROUND(
        (COUNT(*) * SUM(age * imitation) - SUM(age) * SUM(imitation)) /
        SQRT(
            (COUNT(*) * SUM(age * age) - SUM(age) * SUM(age)) *
            (COUNT(*) * SUM(imitation * imitation) - SUM(imitation) * SUM(imitation))
        ),
        4
    ) AS pearson_r
FROM behavioral_data
GROUP BY fieldsite
ORDER BY fieldsite;

-- Overall correlation
SELECT
    'Overall' AS fieldsite,
    COUNT(*) AS n,
    ROUND(
        (COUNT(*) * SUM(age * imitation) - SUM(age) * SUM(imitation)) /
        SQRT(
            (COUNT(*) * SUM(age * age) - SUM(age) * SUM(age)) *
            (COUNT(*) * SUM(imitation * imitation) - SUM(imitation) * SUM(imitation))
        ),
        4
    ) AS pearson_r
FROM behavioral_data;


-- -------------------------------------------------------------------------
-- 5. Rank fieldsites by mean imitation score
-- -------------------------------------------------------------------------
SELECT
    fieldsite,
    ROUND(AVG(imitation), 2) AS mean_imitation,
    RANK() OVER (ORDER BY AVG(imitation) DESC) AS rank_by_imitation
FROM behavioral_data
GROUP BY fieldsite
ORDER BY rank_by_imitation;


-- -------------------------------------------------------------------------
-- 6. Distribution analysis: imitation score buckets
-- -------------------------------------------------------------------------
SELECT
    fieldsite,
    CASE
        WHEN imitation BETWEEN 4 AND 5 THEN '4-5 (Low)'
        WHEN imitation BETWEEN 6 AND 7 THEN '6-7 (Medium)'
        WHEN imitation BETWEEN 8 AND 10 THEN '8-10 (High)'
        ELSE 'Other'
    END AS score_bucket,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY fieldsite), 1) AS pct
FROM behavioral_data
GROUP BY fieldsite, score_bucket
ORDER BY fieldsite, score_bucket;


-- -------------------------------------------------------------------------
-- 7. Window functions: rank observations within each fieldsite
-- -------------------------------------------------------------------------
SELECT
    id,
    fieldsite,
    imitation,
    age,
    RANK() OVER (PARTITION BY fieldsite ORDER BY imitation DESC) AS rank_within_site,
    ROUND(AVG(imitation) OVER (PARTITION BY fieldsite), 2) AS site_mean,
    ROUND(imitation - AVG(imitation) OVER (PARTITION BY fieldsite), 2) AS deviation_from_mean
FROM behavioral_data
ORDER BY fieldsite, rank_within_site
LIMIT 20;


-- -------------------------------------------------------------------------
-- 8. Pairwise comparison across sites (difference in means)
-- -------------------------------------------------------------------------
WITH site_means AS (
    SELECT
        fieldsite,
        AVG(imitation) AS mean_imitation
    FROM behavioral_data
    GROUP BY fieldsite
)
SELECT
    a.fieldsite AS site_a,
    b.fieldsite AS site_b,
    ROUND(a.mean_imitation, 2) AS mean_a,
    ROUND(b.mean_imitation, 2) AS mean_b,
    ROUND(a.mean_imitation - b.mean_imitation, 2) AS mean_difference
FROM site_means a
CROSS JOIN site_means b
WHERE a.fieldsite < b.fieldsite
ORDER BY ABS(a.mean_imitation - b.mean_imitation) DESC;


-- -------------------------------------------------------------------------
-- 9. Missing data audit
-- -------------------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN fieldsite IS NULL THEN 1 ELSE 0 END) AS missing_fieldsite,
    SUM(CASE WHEN imitation IS NULL THEN 1 ELSE 0 END) AS missing_imitation,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END)       AS missing_age,
    COUNT(DISTINCT fieldsite) AS unique_fieldsites
FROM behavioral_data;


-- -------------------------------------------------------------------------
-- 10. Summary table: comprehensive overview
-- -------------------------------------------------------------------------
SELECT
    fieldsite,
    COUNT(*)                          AS n,
    ROUND(MIN(imitation), 1)          AS min_imitation,
    ROUND(MAX(imitation), 1)          AS max_imitation,
    ROUND(AVG(imitation), 2)          AS mean_imitation,
    ROUND(STDDEV(imitation), 2)       AS sd_imitation,
    ROUND(AVG(imitation) - 1.96 * STDDEV(imitation) / SQRT(COUNT(*)), 2) AS ci_lower,
    ROUND(AVG(imitation) + 1.96 * STDDEV(imitation) / SQRT(COUNT(*)), 2) AS ci_upper,
    ROUND(MIN(age), 1)                AS min_age,
    ROUND(MAX(age), 1)                AS max_age,
    ROUND(AVG(age), 2)                AS mean_age,
    ROUND(STDDEV(age), 2)             AS sd_age
FROM behavioral_data
GROUP BY fieldsite
ORDER BY fieldsite;
