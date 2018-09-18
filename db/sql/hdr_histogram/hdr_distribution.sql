DROP FUNCTION hdr_distribution(histogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_distribution(histogram hdrHistogram) RETURNS integer[][] AS $$
  DECLARE
    index integer;
    result integer[][];
    iterator integer[];
  BEGIN
    index := 0;

    iterator[2] := -1;
    iterator := hdr_iteratorNext(histogram, iterator);

    WHILE iterator[0] = 1 LOOP
      result[index] := array[
        hdr_lowestEquivalentValue(histogram, iterator[5]), -- MIN
        iterator[6],                                       -- MAX
        iterator[3]                                        -- COUNT
      ];

      index := index + 1;
      iterator := hdr_iteratorNext(histogram, iterator);
    END LOOP;

    RETURN result;
  END;
$$ LANGUAGE plpgsql STABLE;
