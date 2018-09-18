CREATE OR REPLACE FUNCTION hdr_c_recordValue(hdrHistogram, integer) RETURNS hdrHistogram
  AS 'hdr_c_functions', 'hdr_c_recordValue'
  LANGUAGE C STABLE STRICT;

CREATE OR REPLACE FUNCTION hdr_c_recordValues(hdrHistogram, integer, integer) RETURNS hdrHistogram
  AS 'hdr_c_functions', 'hdr_c_recordValues'
  LANGUAGE C STABLE STRICT;

CREATE OR REPLACE FUNCTION hdr_c_merge(hdrHistogram, hdrHistogram) RETURNS hdrHistogram
  AS 'hdr_c_functions', 'hdr_c_merge'
  LANGUAGE C STABLE STRICT;

DROP FUNCTION hdr_c_initialize(integer, integer, integer);
CREATE OR REPLACE FUNCTION hdr_c_initialize(integer, integer, integer) RETURNS hdrHistogram
  AS 'hdr_c_functions', 'hdr_c_initialize'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_totalCount(hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_totalCount(hdrHistogram) RETURNS integer
  AS 'hdr_c_functions', 'hdr_c_totalCount'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_max(hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_max(hdrHistogram) RETURNS integer
  AS 'hdr_c_functions', 'hdr_c_max'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_min(hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_min(hdrHistogram) RETURNS integer
  AS 'hdr_c_functions', 'hdr_c_min'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_mean(hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_mean(hdrHistogram) RETURNS float
  AS 'hdr_c_functions', 'hdr_c_mean'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_stdDev(hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_stdDev(hdrHistogram) RETURNS float
  AS 'hdr_c_functions', 'hdr_c_stdDev'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_valueAtQuantile(hdrHistogram, float);
CREATE OR REPLACE FUNCTION hdr_c_valueAtQuantile(hdrHistogram, float) RETURNS float
  AS 'hdr_c_functions', 'hdr_c_valueAtQuantile'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_distribution(hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_distribution(hdrHistogram) RETURNS int[][]
  AS 'hdr_c_functions', 'hdr_c_distribution'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_null(histogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_null(histogram hdrHistogram) RETURNS BOOLEAN
  AS 'hdr_c_functions', 'hdr_c_null'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_merge(hdrHistogram, hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_merge(hdrHistogram, hdrHistogram) RETURNS hdrHistogram
  AS 'hdr_c_functions', 'hdr_c_merge'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_group_accum(hdrHistogram, hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_group_accum(hdrHistogram, hdrHistogram) RETURNS hdrHistogram
  AS 'hdr_c_functions', 'hdr_c_group_accum'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_group_final(hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_c_group_final(hdrHistogram) RETURNS hdrHistogram
  AS 'hdr_c_functions', 'hdr_c_group_final'
  LANGUAGE C STABLE;

DROP FUNCTION hdr_c_cast_to_hdr(jsonb);
CREATE OR REPLACE FUNCTION hdr_c_cast_to_hdr(jsonb) RETURNS hdrHistogram
  AS 'hdr_c_functions', 'hdr_c_cast_to_hdr'
  LANGUAGE C STABLE;

DROP AGGREGATE hdr_c_group(hdrHistogram);
CREATE AGGREGATE hdr_c_group(hdrHistogram)
(
  STYPE = hdrHistogram,
  SFUNC = hdr_c_group_accum,
  FINALFUNC = hdr_c_group_final
);
