DROP FUNCTION hdr_sizeOfEquivalentValueRange(histogram hdrHistogram, v integer);
CREATE OR REPLACE FUNCTION hdr_sizeOfEquivalentValueRange(histogram hdrHistogram, v integer) RETURNS INTEGER AS $$
  DECLARE
    bucketIdx integer;
    subBucketIdx integer;
    adjustedBucket integer;
  BEGIN
    bucketIdx := hdr_getBucketIndex(histogram, v);
    subBucketIdx := hdr_getSubBucketIdx(histogram, v, bucketIdx);
    adjustedBucket := bucketIdx;

    IF subBucketIdx >= histogram.subBucketCount THEN
      adjustedBucket := adjustedBucket + 1;
    END IF;

    RETURN (1 << (histogram.unitMagnitude + adjustedBucket));
  END;
$$ LANGUAGE plpgsql STABLE;
