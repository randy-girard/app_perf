DROP FUNCTION hdr_lowestEquivalentValue(histogram hdrHistogram, v integer);
CREATE OR REPLACE FUNCTION hdr_lowestEquivalentValue(histogram hdrHistogram, v integer) RETURNS INTEGER AS $$
  DECLARE
    bucketIdx integer;
    subBucketIdx integer;
  BEGIN
    bucketIdx := hdr_getBucketIndex(histogram, v);
    subBucketIdx := hdr_getSubBucketIdx(histogram, v, bucketIdx);

    RETURN hdr_valueFromIndex(histogram, bucketIdx, subBucketIdx);
  END;
$$ LANGUAGE plpgsql STABLE;
