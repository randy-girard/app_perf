DROP FUNCTION hdr_bitLen(x integer);
CREATE OR REPLACE FUNCTION hdr_bitLen(x integer) RETURNS INTEGER AS $$
  DECLARE
    n integer;
  BEGIN
    n := 0;

    WHILE x >= 32768 LOOP
      x := x >> 16;
      n := n + 16;
    END LOOP;

    IF x >= 128 THEN
      x := x >> 8;
      n := n + 8;
    END IF;

    IF x >= 8 THEN
      x := x >> 4;
      n := n + 4;
    END IF;

    IF x >= 2 THEN
      x := x >> 2;
      n := n + 2;
    END IF;

    IF x >= 1 THEN
      n := n + 1;
    END IF;

    RETURN n;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
