{{config({
    "materialized": "table",
    "schema": "qa",
    "tags":"hourly",
    "unique_key":"id"
  })
}}

{% set rudder_relations = get_rudder_relations(schema=["mm_mobile_test", "mm_mobile_beta"], database='RAW') %}
{{ union_relations(relations = rudder_relations) }}