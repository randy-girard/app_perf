DROP FUNCTION hdr_valueFromIndex(histogram hdrHistogram, bucketIdx integer, subBucketIdx integer);
CREATE OR REPLACE FUNCTION hdr_valueFromIndex(histogram hdrHistogram, bucketIdx integer, subBucketIdx integer) RETURNS INTEGER AS $$
  SELECT (subBucketIdx << (bucketIdx + histogram.unitMagnitude));
$$ LANGUAGE sql STABLE;
