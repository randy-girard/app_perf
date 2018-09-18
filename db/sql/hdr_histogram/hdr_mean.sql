DROP FUNCTION hdr_mean(histogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_mean(histogram hdrHistogram) RETURNS DECIMAL AS $$
  DECLARE
    total decimal;
    iterator integer[];
  BEGIN
    IF histogram.totalCount = 0 THEN
      RETURN 0;
    END IF;

    total := 0;

    iterator[2] := -1;

    iterator := hdr_iteratorNext(histogram, iterator);

    WHILE iterator[0] = 1 LOOP
      IF iterator[3] != 0 THEN
        total := total + (iterator[3] * hdr_medianEquivalentValue(histogram, iterator[5]));
      END IF;
      iterator := hdr_iteratorNext(histogram, iterator);
    END LOOP;

    RETURN (total / histogram.totalCount);
  END;
$$ LANGUAGE plpgsql STABLE;
