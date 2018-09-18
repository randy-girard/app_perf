DROP FUNCTION hdr_rIteratorNext(histogram hdrHistogram, iterator integer[]);
CREATE OR REPLACE FUNCTION hdr_rIteratorNext(histogram hdrHistogram, iterator integer[]) RETURNS integer[] AS $$
  BEGIN
    iterator[0] = 1;
    iterator[2] = -1;

    WHILE iterator[0] = 1 LOOP
      iterator := hdr_iteratorNext(histogram, iterator);

      IF iterator[3] != 0 THEN
        iterator[7] := iterator[3];
        return iterator;
      END IF;
    END LOOP;

    iterator[0] := 0;
    return iterator;
  END;
$$ LANGUAGE plpgsql STABLE;
