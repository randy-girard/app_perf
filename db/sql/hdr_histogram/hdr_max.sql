DROP FUNCTION hdr_max(histogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_max(histogram hdrHistogram) RETURNS INTEGER AS $$
  DECLARE
    max integer;
    iterator integer[];
  BEGIN
    iterator[0] := 1;
    iterator[2] := -1;

    WHILE iterator[0] = 1 LOOP
      iterator := hdr_iteratorNext(histogram, iterator);

      IF iterator[3] != 0 THEN
        max := iterator[6];
      END IF;
    END LOOP;

    RETURN hdr_highestEquivalentValue(histogram, max);
  END;
$$ LANGUAGE plpgsql STABLE;
