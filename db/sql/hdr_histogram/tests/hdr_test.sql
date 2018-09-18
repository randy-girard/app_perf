DROP FUNCTION hdr_test();
CREATE OR REPLACE FUNCTION hdr_test() RETURNS VOID AS $$
  DECLARE
    counts integer[];

    min integer;
    max integer;
    total integer;
    stdDev decimal;
    mean decimal;

    histogram hdrHistogram;
    histogram1 hdrHistogram;
    histogram2 hdrHistogram;
  BEGIN
    histogram := hdr_c_initialize(0, 60000, 1);
    histogram := hdr_c_recordValue(histogram, 500);
    histogram := hdr_c_recordValue(histogram, 1000);

    min := hdr_c_min(histogram);
    if min != 496 then
      raise notice 'Min not 496: %', min;
    end if;

    max := hdr_c_max(histogram);
    if max != 1023 then
      raise notice 'Max not 1023: %', max;
    end if;

    total := hdr_c_totalCount(histogram);
    if total != 2 then
      raise notice 'Total not 2: %', total;
    end if;

    stdDev := hdr_c_stdDev(histogram);
    if stdDev != 252 then
      raise notice 'Stddev not 252: %', stdDev;
    end if;

    mean := hdr_c_mean(histogram);
    if mean != 756 then
      raise notice 'Mean not 756: %', mean;
    end if;




    histogram1 := hdr_c_initialize(0, 60000, 1);
    histogram1 := hdr_c_recordValue(histogram1, 500);

    histogram2 := hdr_c_initialize(0, 60000, 1);
    histogram2 := hdr_c_recordValue(histogram2, 500);

    histogram := hdr_c_merge(histogram1, histogram2);

    min := hdr_c_min(histogram);
    if min != 496 then
      raise notice 'Min not 496: %', min;
    end if;

    max := hdr_c_max(histogram);
    if max != 511 then
      raise notice 'Max not 511: %', max;
    end if;

    total := hdr_c_totalCount(histogram);
    if total != 2 then
      raise notice 'Total not 2: %', total;
    end if;

    stdDev := hdr_c_stdDev(histogram);
    if stdDev != 0 then
      raise notice 'Stddev not 0: %', stdDev;
    end if;

    mean := hdr_c_mean(histogram);
    if mean != 504 then
      raise notice 'Mean not 504: %', mean;
    end if;
  END;
$$ LANGUAGE plpgsql;
