DROP FUNCTION hdr_totalCount(histogram hdrHistogram);
CREATE OR REPLACE FUNCTION hdr_totalCount(histogram hdrHistogram) RETURNS INTEGER AS $$
  SELECT histogram.totalCount;
$$ LANGUAGE sql STABLE;
