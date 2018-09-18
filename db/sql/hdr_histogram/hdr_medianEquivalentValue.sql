DROP FUNCTION hdr_medianEquivalentValue(histogram hdrHistogram, v integer);
CREATE OR REPLACE FUNCTION hdr_medianEquivalentValue(histogram hdrHistogram, v integer) RETURNS INTEGER AS $$
  SELECT hdr_lowestEquivalentValue(histogram, v) + (hdr_sizeOfEquivalentValueRange(histogram, v) >> 1);
$$ LANGUAGE sql STABLE;
