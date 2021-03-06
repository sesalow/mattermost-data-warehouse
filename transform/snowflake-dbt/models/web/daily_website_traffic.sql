{{config({
    "materialized": 'incremental',
    "unique_key": 'id',
    "schema": "web",
    "tags":"preunion"
  })
}}

{% set rudder_relations = get_rudder_relations(schema=["mattermostcom", "portal_prod", "support_portal"], database='RAW', table_inclusions="'pages'") %}
{{ union_relations(relations = rudder_relations) }}