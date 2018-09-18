DROP FUNCTION hdr_getBucketIndex(histogram hdrHistogram, v integer);
CREATE OR REPLACE FUNCTION hdr_getBucketIndex(histogram hdrHistogram, v integer) RETURNS INTEGER AS $$
  SELECT (hdr_bitLen(v | histogram.subBucketMask) - histogram.unitMagnitude) - (histogram.subBucketHalfCountMagnitude + 1);
$$ LANGUAGE sql STABLE;
