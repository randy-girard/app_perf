DROP FUNCTION hdr_iteratorNext(histogram hdrHistogram, iterator integer[]);
CREATE OR REPLACE FUNCTION hdr_iteratorNext(histogram hdrHistogram, iterator integer[]) RETURNS integer[] AS $$
  BEGIN
    iterator[1] := COALESCE(iterator[1], 0);
    iterator[2] := COALESCE(iterator[2], 0);
    iterator[3] := COALESCE(iterator[3], 0);
    iterator[4] := COALESCE(iterator[4], 0);
    iterator[5] := COALESCE(iterator[5], 0);

    IF iterator[4] >= histogram.totalCount THEN
      iterator[0] := 0;
      RETURN iterator;
    END IF;

    iterator[2] := iterator[2] + 1;
    IF iterator[2] >= histogram.subBucketCount THEN
      iterator[2] := histogram.subBucketHalfCount;
      iterator[1] := iterator[1] + 1;
    END IF;

    IF iterator[1] >= histogram.bucketCount THEN
      iterator[0] := 0;
      RETURN iterator;
    END IF;

    iterator[3] := hdr_getCountAtIndex(histogram, iterator[1], iterator[2]);
    iterator[4] := iterator[4] + iterator[3];
    iterator[5] := hdr_valueFromIndex(histogram, iterator[1], iterator[2]);
    iterator[6] := hdr_highestEquivalentValue(histogram, iterator[5]);

    iterator[0] := 1;

    RETURN iterator;
  END;
$$ LANGUAGE plpgsql STABLE;
