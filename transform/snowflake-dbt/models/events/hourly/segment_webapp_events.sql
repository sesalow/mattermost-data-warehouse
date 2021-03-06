{{config({
    "materialized": "incremental",
    "schema": "events",
    "tags":"preunion"
  })
}}

SELECT s.*
FROM (
SELECT
    segment.*
FROM {{ source('mattermost2', 'event') }} segment
     LEFT JOIN (
                SELECT user_id, MIN(TIMESTAMP::DATE) AS MIN_DATE
                FROM {{ source('mm_telemetry_prod', 'event') }}
                GROUP BY 1
              ) rudder
        ON segment.user_id = rudder.user_id AND segment.timestamp::DATE >= rudder.MIN_DATE
{% if is_incremental() %}

WHERE rudder.user_id is NULL
AND segment.timestamp::date >= (SELECT MAX(timestamp::date) FROM {{ this }}) - INTERVAL '1 DAYS'
AND segment.timestamp::date <= CURRENT_TIMESTAMP
AND segment.timestamp::date >= '2019-02-01'
) s

{% else %}

WHERE rudder.user_id is NULL
AND segment.timestamp::date <= CURRENT_TIMESTAMP
AND segment.timestamp::date >= '2019-02-01'
) s

{% endif %}
{% if is_incremental() %}

LEFT JOIN 
        (
          SELECT DISTINCT ID AS JOIN_KEY
          FROM {{ this }}
          WHERE timestamp::date >= (SELECT MAX(timestamp::date) FROM {{ this }}) - INTERVAL '1 DAYS'
        ) a
  ON s.id = a.JOIN_KEY
WHERE s.timestamp::date >= (SELECT MAX(timestamp::date) FROM {{ this }}) - INTERVAL '1 DAYS'
AND s.timestamp <= CURRENT_TIMESTAMP
AND a.JOIN_KEY IS NULL

{% else %}

s.timestamp <= CURRENT_TIMESTAMP

{% endif %}