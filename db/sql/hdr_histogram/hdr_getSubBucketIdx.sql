DROP FUNCTION hdr_getSubBucketIdx(histogram hdrHistogram, v integer, idx integer);
CREATE OR REPLACE FUNCTION hdr_getSubBucketIdx(histogram hdrHistogram, v integer, idx integer) RETURNS INTEGER AS $$
  SELECT (v >> (idx + histogram.unitMagnitude));
$$ LANGUAGE sql STABLE;
