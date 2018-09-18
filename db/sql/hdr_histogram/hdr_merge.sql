DROP FUNCTION hdr_merge(histogram hdrHistogram, fromHistogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_merge(histogram hdrHistogram, fromHistogram hdrHistogram) RETURNS hdrHistogram AS $$
  DECLARE
    dropped integer;
    v integer;
    c integer;
    iterator integer[];
  BEGIN
    dropped := 0;

    IF hdr_null(histogram) THEN
      histogram := hdr_initialize(0, 60000, 1);
    END IF;

    iterator[2] := -1;
    iterator := hdr_rIteratorNext(fromHistogram, iterator);

    WHILE iterator[0] = 1 LOOP
      v := iterator[5];
      c := iterator[3];

      histogram := hdr_recordValues(histogram, v, c);
      -- IF histogram != NULL THEN
      --   dropped = dropped + 1
      -- END IF;
      iterator := hdr_rIteratorNext(fromHistogram, iterator);
    END LOOP;

    RETURN histogram;
  END;
$$ LANGUAGE plpgsql STABLE;
