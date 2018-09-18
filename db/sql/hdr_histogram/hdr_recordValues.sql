DROP FUNCTION hdr_recordValues(histogram hdrHistogram, v integer, n integer);
CREATE OR REPLACE FUNCTION hdr_recordValues(histogram hdrHistogram, v integer, n integer) RETURNS hdrHistogram AS $$
  DECLARE
    idx integer;
  BEGIN
    idx := hdr_countsIndexFor(histogram, v) + 1;

    IF idx < 0 OR histogram.countsLen <= idx THEN
      RAISE NOTICE 'Value % is too large to be recorded', v;
      RETURN histogram;
    END IF;

    histogram.counts[idx] := histogram.counts[idx] + n;
    histogram.totalCount := histogram.totalCount + n;

    RETURN histogram;
  END;
$$ LANGUAGE plpgsql STABLE;
