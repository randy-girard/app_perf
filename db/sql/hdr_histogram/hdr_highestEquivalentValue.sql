DROP FUNCTION hdr_highestEquivalentValue(histogram hdrHistogram, v integer);
CREATE OR REPLACE FUNCTION hdr_highestEquivalentValue(histogram hdrHistogram, v integer) RETURNS INTEGER AS $$
  SELECT hdr_nextNonEquivalentValue(histogram, v) - 1;
$$ LANGUAGE sql STABLE;
