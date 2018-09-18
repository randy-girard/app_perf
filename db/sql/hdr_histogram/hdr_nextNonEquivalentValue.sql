DROP FUNCTION hdr_nextNonEquivalentValue(histogram hdrHistogram, v integer);
CREATE OR REPLACE FUNCTION hdr_nextNonEquivalentValue(histogram hdrHistogram, v integer) RETURNS INTEGER AS $$
  SELECT hdr_lowestEquivalentValue(histogram, v) + hdr_sizeOfEquivalentValueRange(histogram, v);
$$ LANGUAGE sql STABLE;
