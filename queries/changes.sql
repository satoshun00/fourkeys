# Changes Table
SELECT 
source,
CASE
  WHEN source LIKE 'github%' OR (source LIKE 'gitlab%' AND REGEXP_CONTAINS(LOWER(e.metadata), r'repository')) 
    THEN JSON_EXTRACT_SCALAR(e.metadata, '$.repository.name')
  WHEN source LIKE 'gitlab%'
    THEN JSON_EXTRACT_SCALAR(e.metadata, '$.project.name')
  ELSE 'unknown'
END AS repo,
event_type,
JSON_EXTRACT_SCALAR(commit, '$.id') change_id,
TIMESTAMP_TRUNC(TIMESTAMP(JSON_EXTRACT_SCALAR(commit, '$.timestamp')),second) as time_created,
FROM four_keys.events_raw e,
UNNEST(JSON_EXTRACT_ARRAY(e.metadata, '$.commits')) as commit
WHERE event_type = "push"
GROUP BY 1,2,3,4,5