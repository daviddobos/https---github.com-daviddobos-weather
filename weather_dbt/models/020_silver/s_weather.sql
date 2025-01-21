WITH b_weather AS (
    SELECT 
        *
    FROM {{ref('b_weather') }}
),

country_codes AS (
    SELECT
        *
    FROM {{ source('int', 'country_codes') }}
),

join_country_cd AS (
    SELECT
        b_weather.*
        ,country_codes.country_cd AS country_cd
    FROM b_weather
    JOIN country_codes
    ON b_weather.country_nm = country_codes.country_nm
),

gen_sk AS (
    SELECT
        *
        ,{{ gen_sk(['forecast_dt','country_cd', 'city_nm']) }} AS weather_pk
    FROM join_country_cd
),

unit_conversion AS (
    SELECT
        *
        ,gust_kph_no * {{ var('km_to_mi') }} AS gust_miph_no
        ,temp_c_no * {{ var('cels_to_fahr') }} AS temp_f_no
        ,temp_c_no * {{ var('cels_to_kel') }} AS temp_k_no
        ,heatindex_c_no * {{ var('cels_to_fahr') }} AS heatindex_f_no
        ,heatindex_c_no * {{ var('cels_to_kel') }} AS heatindex_k_no
        ,vis_km_no * {{ var('km_to_mi') }} AS vis_mi_no
        ,wind_kph_no * {{ var('km_to_mi') }} AS wind_miph_no
        ,windchill_c_no * {{ var('cels_to_fahr') }} AS windchill_f_no
        ,windchill_c_no * {{ var('cels_to_kel') }} AS windchill_k_no
    FROM gen_sk
),

weather_categories AS (
    SELECT
        *
        -- Rain Chance Category
        ,CASE
            WHEN rain_chance_no BETWEEN 0 AND 20 THEN 'Very Low'
            WHEN rain_chance_no BETWEEN 21 AND 40 THEN 'Low'
            WHEN rain_chance_no BETWEEN 41 AND 60 THEN 'Moderate'
            WHEN rain_chance_no BETWEEN 61 AND 80 THEN 'High'
            WHEN rain_chance_no BETWEEN 81 AND 100 THEN 'Very High'
            ELSE 'Unknown'
        END AS rain_chance_cd

        -- Snow Chance Category
        ,CASE
            WHEN snow_chance_no BETWEEN 0 AND 20 THEN 'Very Low'
            WHEN snow_chance_no BETWEEN 21 AND 40 THEN 'Low'
            WHEN snow_chance_no BETWEEN 41 AND 60 THEN 'Moderate'
            WHEN snow_chance_no BETWEEN 61 AND 80 THEN 'High'
            WHEN snow_chance_no BETWEEN 81 AND 100 THEN 'Very High'
            ELSE 'Unknown'
        END AS snow_chance_cd

        -- Cloud Coverage Category
        ,CASE
            WHEN cloud_coverage_no BETWEEN 0 AND 20 THEN 'Clear'
            WHEN cloud_coverage_no BETWEEN 21 AND 40 THEN 'Partly Cloudy'
            WHEN cloud_coverage_no BETWEEN 41 AND 60 THEN 'Cloudy'
            WHEN cloud_coverage_no BETWEEN 61 AND 80 THEN 'Overcast'
            WHEN cloud_coverage_no BETWEEN 81 AND 100 THEN 'Completely Overcast'
            ELSE 'Unknown'
        END AS cloud_coverage_cd

        -- Feels Like Temperature Category
        ,CASE
            WHEN temp_feelslike_no <= 0 THEN 'Very Cold'
            WHEN temp_feelslike_no BETWEEN 1 AND 10 THEN 'Cold'
            WHEN temp_feelslike_no BETWEEN 11 AND 20 THEN 'Cool'
            WHEN temp_feelslike_no BETWEEN 21 AND 30 THEN 'Warm'
            WHEN temp_feelslike_no BETWEEN 31 AND 40 THEN 'Hot'
            WHEN temp_feelslike_no > 40 THEN 'Very Hot'
            ELSE 'Unknown'
        END AS temp_feels_like_cd

        -- Humidity Category
        ,CASE
            WHEN humidity_no BETWEEN 0 AND 20 THEN 'Very Low'
            WHEN humidity_no BETWEEN 21 AND 40 THEN 'Low'
            WHEN humidity_no BETWEEN 41 AND 60 THEN 'Moderate'
            WHEN humidity_no BETWEEN 61 AND 80 THEN 'High'
            WHEN humidity_no BETWEEN 81 AND 100 THEN 'Very High'
            ELSE 'Unknown'
        END AS humidity_cd

    FROM unit_conversion
),

reorder AS (
    SELECT
        weather_pk
        ,forecast_dt
        ,city_nm
        ,country_cd
        ,country_nm
        ,cloud_coverage_no
        ,cloud_coverage_cd
        ,gust_kph_no
        ,gust_miph_no
        ,heatindex_c_no
        ,heatindex_f_no
        ,heatindex_k_no
        ,humidity_no
        ,humidity_cd
        ,is_day_flg
        ,precip_mm_no
        ,pressure_mb_no
        ,temp_c_no
        ,temp_f_no
        ,temp_k_no
        ,temp_feelslike_no
        ,temp_feels_like_cd
        ,date_dtt
        ,time_epoch
        ,rain_chance_no
        ,rain_chance_cd
        ,snow_chance_no
        ,snow_chance_cd
        ,uv_no
        ,vis_km_no
        ,vis_mi_no
        ,wind_dir_cd
        ,wind_kph_no
        ,wind_miph_no
        ,windchill_c_no
        ,windchill_f_no
        ,windchill_k_no
        ,p_load_dt
    FROM weather_categories
)

SELECT * FROM reorder