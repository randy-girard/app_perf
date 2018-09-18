DROP FUNCTION hdr_initialize(min integer, max integer, sigfigs integer);
CREATE OR REPLACE FUNCTION hdr_initialize(min integer, max integer, sigfigs integer) RETURNS hdrHistogram AS $$
  DECLARE
    histogram histogram;
  BEGIN
    histogram.minValue = min;
    histogram.maxValue = max;
    histogram.significantFigures = sigfigs;

    return hdr_histogram(histogram);
  END;
$$ LANGUAGE plpgsql STABLE;
