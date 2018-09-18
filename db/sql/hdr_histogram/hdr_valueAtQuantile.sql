DROP FUNCTION hdr_valueAtQuantile(histogram hdrHistogram, q decimal);
CREATE OR REPLACE FUNCTION hdr_valueAtQuantile(histogram hdrHistogram, q decimal) RETURNS INTEGER AS $$
  DECLARE
    total integer;
    countAtPercentile decimal;

    iterator integer[];
  BEGIN
    IF q > 100 THEN
      q := 100;
    END IF;

    total := 0;
    countAtPercentile := (((q / 100.0) * histogram.totalCount) + 0.5);

    iterator[0] := 1;
    iterator[2] := -1;

    WHILE iterator[0] = 1 LOOP
      iterator := hdr_iteratorNext(histogram, iterator);

      total := total + iterator[3];

		  IF total >= countAtPercentile THEN
			  RETURN hdr_highestEquivalentValue(histogram, iterator[5]);
		  END IF;
    END LOOP;

    RETURN 0;
  END;
$$ LANGUAGE plpgsql STABLE;
