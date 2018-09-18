DROP FUNCTION hdr_stdDev(histogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_stdDev(histogram hdrHistogram) RETURNS DECIMAL AS $$
  DECLARE
    mean decimal;
    dev decimal;
    geometricDevTotal decimal;

    iterator integer[];
  BEGIN
    IF histogram.totalCount = 0 THEN
      RETURN 0;
    END IF;

    mean := hdr_mean(histogram);
    geometricDevTotal := 0.0;

    iterator[2] := -1;
    iterator := hdr_iteratorNext(histogram, iterator);

    WHILE iterator[0] = 1 LOOP
      IF iterator[3] != 0 THEN
        dev := hdr_medianEquivalentValue(histogram, iterator[5]) - mean;
			  geometricDevTotal := geometricDevTotal + (dev * dev) * iterator[3];
      END IF;
      iterator := hdr_iteratorNext(histogram, iterator);
    END LOOP;

    RETURN sqrt(geometricDevTotal / histogram.totalCount);
  END;
$$ LANGUAGE plpgsql STABLE;
