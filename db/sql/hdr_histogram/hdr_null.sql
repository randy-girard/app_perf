DROP FUNCTION hdr_null(histogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_null(histogram hdrHistogram) RETURNS BOOLEAN AS $$
  BEGIN
    if histogram.unitMagnitude IS NULL AND
       histogram.totalCount IS NULL
    THEN
      return true;
    end if;

    return false;
  END;
$$ LANGUAGE plpgsql STABLE;
