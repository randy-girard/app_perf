DROP FUNCTION hdr_getCountAtIndex(histogram hdrHistogram, bucketIdx integer, subBucketIdx integer);
CREATE OR REPLACE FUNCTION hdr_getCountAtIndex(histogram hdrHistogram, bucketIdx integer, subBucketIdx integer) RETURNS INTEGER AS $$
  SELECT histogram.counts[hdr_countsIndex(histogram, bucketIdx, subBucketIdx) + 1];
$$ LANGUAGE sql STABLE;
