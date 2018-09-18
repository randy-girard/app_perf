   DROP FUNCTION unnest_3d;
   CREATE OR REPLACE FUNCTION unnest_3d(anyarray)
     RETURNS table(start integer, finish integer, count integer) AS
   $BODY$
     SELECT
       $1[i][1]::integer AS start,
       $1[i][2]::integer as finish,
       $1[i][3]::integer as count
     FROM
       generate_series(array_lower($1,1), array_upper($1,1)) i
   $BODY$
     LANGUAGE 'sql' IMMUTABLE;


select
  timestamp,
  s.start,
  s.finish,
  SUM(value),
  SUM(s.count) OVER (PARTITION by metric_id, timestamp, s.start, s.finish order by metric_id, timestamp, s.start, s.finish),
  (CASE WHEN SUM(value) * 0.5 > s.start AND SUM(value) * 0.5 <= finish THEN 1 else 0 END) as perc_50
FROM
  metric_data,
  unnest_3d(histogram::text[][]) AS s
where histogram != '{}' and value is not null and metric_id = 72
group by 1, 2, 3 order by 1, 2, 3;



-- ALTER TABLE metric_data add COLUMN hdr_histogram text[];
-- UPDATE metric_data SET hdr_histogram = hdr_histogram(histogram);
