DROP FUNCTION hdr_min(histogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_min(histogram hdrHistogram) RETURNS INTEGER AS $$
  DECLARE
    min integer;
    iterator integer[];
  BEGIN
    iterator[0] := 1;
    iterator[2] := -1;

    min := 0;

    WHILE iterator[0] = 1 LOOP
      iterator := hdr_iteratorNext(histogram, iterator);

      IF iterator[3] != 0 AND min = 0 THEN
        min := iterator[6];
      END IF;
    END LOOP;

    RETURN hdr_lowestEquivalentValue(histogram, min);
  END;
$$ LANGUAGE plpgsql STABLE;
