DROP FUNCTION hdr_group_accum (hdrHistogram, hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_group_accum (hdrHistogram, hdrHistogram) RETURNS hdrHistogram AS $$
  BEGIN
    RETURN hdr_merge($1, $2);
  END;
$$ LANGUAGE plpgsql STABLE;
