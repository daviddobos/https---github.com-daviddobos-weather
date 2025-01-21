WITH ld_astro AS (
    SELECT 
        *
    FROM {{ source('landing_delta', 'weather_astro') }}
),

b_astro AS (
    SELECT
        CONVERT(INT, moon_illumination) AS moon_illumination_no
        ,CONVERT(VARCHAR(20), moon_phase) AS moon_phase_cd
        ,CONVERT(TIME(0), moonrise) AS moonrise_t
        ,CONVERT(TIME(0), moonset) AS moonset_t
        ,CONVERT(TIME(0), sunrise) AS sunrise_t
        ,CONVERT(TIME(0), sunset) AS sunset_t
        ,CONVERT(VARCHAR(50), city) AS city_nm
        ,CONVERT(VARCHAR(50), country) AS country_nm
        ,CONVERT(DATETIME2(6), forecast_date) AS forecast_dt
        ,CONVERT(DATETIME2(6), p_load_dt) AS p_load_dt
    FROM ld_astro
)

SELECT * FROM b_astro