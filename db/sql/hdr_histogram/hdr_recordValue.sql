DROP FUNCTION hdr_recordValue(histogram hdrHistogram, v integer);
CREATE OR REPLACE FUNCTION hdr_recordValue(histogram hdrHistogram, v integer) RETURNS hdrHistogram AS $$
  SELECT hdr_recordValues(histogram, v, 1);
$$ LANGUAGE sql STABLE;
