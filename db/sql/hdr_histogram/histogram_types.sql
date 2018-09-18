DROP TYPE histogram;
CREATE TYPE histogram AS (
  minValue integer,
  maxValue integer,
  significantFigures integer,
  counts integer[]
);

DROP TYPE hdrHistogram;
CREATE TYPE hdrHistogram AS (
  lowestTrackableValue        integer,
	highestTrackableValue       integer,
	unitMagnitude               integer,
	significantFigures          integer,
	subBucketHalfCountMagnitude integer,
	subBucketHalfCount          integer,
	subBucketMask               integer,
	subBucketCount              integer,
	bucketCount                 integer,
	countsLen                   integer,
	totalCount                  integer,
	counts                      integer[]
);

DROP TYPE hdrHistogram CASCADE;
CREATE TYPE hdrHistogram;
CREATE FUNCTION hdr_histogram_in(cstring)
    RETURNS hdrHistogram
    AS 'hdr_c_functions'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION hdr_histogram_out(hdrHistogram)
    RETURNS cstring
    AS 'hdr_c_functions'
    LANGUAGE C IMMUTABLE STRICT;

DROP FUNCTION hdr_histogram_recv(internal);
CREATE FUNCTION hdr_histogram_recv(internal)
   RETURNS hdrHistogram
   AS 'hdr_c_functions'
   LANGUAGE C IMMUTABLE STRICT;

DROP FUNCTION hdr_histogram_send;
CREATE FUNCTION hdr_histogram_send(hdrHistogram)
   RETURNS bytea
   AS 'hdr_c_functions'
   LANGUAGE C IMMUTABLE STRICT;


CREATE TYPE hdrHistogram (
   internallength = VARIABLE,
   input = hdr_histogram_in,
   output = hdr_histogram_out,
   receive = hdr_histogram_recv,
   send = hdr_histogram_send,
   alignment = integer
);

alter table metric_data add column hdr_histogram hdrHistogram;

update metric_data set hdr_histogram = '(1,1,0,2,7,128,255,256,1,256,3,"[0:256]={0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}")';
select * from metric_data limit 1;

select
  hdr_c_min(hdr_histogram) as min,
  hdr_c_max(hdr_histogram) as max
from
  metric_data
limit 1;

select hdr_c_min(hdr_histogram), hdr_c_max(hdr_histogram), hdr_c_max(hdr_c_recordValue(hdr_c_initialize(0, 60000, 1), 500)) from metric_data limit 1;

update metric_data set hdr_histogram = hdr_c_cast_to_hdr(histogram);



select timestamp, hdr_c_group(hdr_histogram) from metric_data group by 1;


explain analyze with c as (select hdr_histogram from metric_data limit 1) select hdr_c_merge(hdr_histogram, hdr_histogram) from c, generate_series(1, 100000);


make clean; make; cp hdr_c_functions.so /usr/local/lib/postgresql/
