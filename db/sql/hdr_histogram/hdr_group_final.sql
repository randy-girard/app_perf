DROP FUNCTION hdr_group_final(hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_group_final(hdrHistogram) RETURNS hdrHistogram AS $$
  BEGIN
    RETURN $1;
  END;
$$ LANGUAGE plpgsql STABLE;
