DROP FUNCTION hdr_countsIndexFor(histogram hdrHistogram, v integer);
CREATE OR REPLACE FUNCTION hdr_countsIndexFor(histogram hdrHistogram, v integer) RETURNS INTEGER AS $$
  DECLARE
    bucketIdx integer;
    subBucketIdx integer;
  BEGIN
    bucketIdx := hdr_getBucketIndex(histogram, v);
    subBucketIdx := hdr_getSubBucketIdx(histogram, v, bucketIdx);

    RETURN hdr_countsIndex(histogram, bucketIdx, subBucketIdx);
  END;
$$ LANGUAGE plpgsql STABLE;
