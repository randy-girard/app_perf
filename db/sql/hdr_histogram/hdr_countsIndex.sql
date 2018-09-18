DROP FUNCTION hdr_countsIndex(histogram hdrHistogram, bucketIdx integer, subBucketIdx integer);
CREATE OR REPLACE FUNCTION hdr_countsIndex(histogram hdrHistogram, bucketIdx integer, subBucketIdx integer) RETURNS INTEGER AS $$
  SELECT ((bucketIdx + 1) << histogram.subBucketHalfCountMagnitude) + (subBucketIdx - histogram.subBucketHalfCount);
$$ LANGUAGE sql STABLE;
