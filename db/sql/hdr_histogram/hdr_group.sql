DROP AGGREGATE hdr_group(hdrHistogram);
CREATE AGGREGATE hdr_group(hdrHistogram)
(
  STYPE = hdrHistogram,
  SFUNC = hdr_group_accum,
  FINALFUNC = hdr_group_final
);
