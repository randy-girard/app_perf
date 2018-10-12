class AddHistogramPlpgsqlFunctions < ActiveRecord::Migration
  def change
    execute <<-EOF
      DROP TYPE IF EXISTS floatrange CASCADE;
      CREATE TYPE floatrange AS RANGE (
          subtype = float8,
          subtype_diff = float8mi
      );

      DROP TYPE IF EXISTS histogram_result CASCADE;
      CREATE TYPE histogram_result AS (
      	count INTEGER,
      	bucket INTEGER,
      	range floatrange
      );

      CREATE OR REPLACE FUNCTION hist_sfunc(state histogram_result[], val float8, min float8, max float8, nbuckets INTEGER) RETURNS histogram_result[] AS $$
      DECLARE
        bucket INTEGER;
        width float8;
        i INTEGER;
      BEGIN
        -- width_bucket uses nbuckets + 1 (!) and starts at 1.
        bucket := width_bucket(val, min, max, nbuckets - 1) - 1;

        -- Init the array with the correct number of 0's so the caller doesn't see NULLs
        IF state[0] IS NULL THEN
          width := (max - min) / (nbuckets - 1);
          FOR i IN SELECT * FROM generate_series(0, nbuckets - 1) LOOP
            state[i] := (0, i, floatrange(i * width, (i + 1) * width));
          END LOOP;
        END IF;

        state[bucket] = (state[bucket].count + 1, state[bucket].bucket, state[bucket].range);

        RETURN state;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;

      CREATE AGGREGATE histogram(float8, float8, float8, INTEGER) (
             SFUNC = hist_sfunc,
             STYPE = histogram_result[]
      );

      CREATE OR REPLACE FUNCTION histobar(v float8, tick_size float8)
      RETURNS TEXT AS $$
      	SELECT repeat('=', (v * tick_size)::integer);
      $$ LANGUAGE SQL;

      CREATE OR REPLACE FUNCTION show_histogram(h histogram_result[])
      RETURNS TABLE(bucket INTEGER, range floatrange, count INTEGER, bar TEXT, cumbar TEXT, cumsum INTEGER, cumpct NUMERIC) AS $$
      DECLARE
      	r histogram_result;
      	min_count integer := (select min(x.count) from unnest(h) as x);
      	max_count integer := (select max(x.count) from unnest(h) as x);
      	total_count integer := (select sum(x.count) from unnest(h) as x);
      	bar_max_width integer := 30;
      	bar_tick_size float8 := bar_max_width / (max_count - min_count)::float8;
      	bar text;
      	cumsum integer := 0;
      	cumpct numeric;
      BEGIN
      	FOREACH r IN ARRAY h LOOP
      		IF r.bucket IS NULL THEN
      			CONTINUE;
      		END IF;

      		cumsum := cumsum + r.count;
      		cumpct := (cumsum::numeric / total_count);
      		bar := histobar(r.count, bar_tick_size);
      		RETURN QUERY VALUES (
      			r.bucket,
      			r.range,
      			r.count,
      			bar,
      			histobar(cumpct, bar_max_width),
      			cumsum,
      			cumpct
      		);
      	END loop;
      END;
      $$ LANGUAGE plpgsql;

      CREATE OR REPLACE FUNCTION histogram_count(h histogram_result[])
      RETURNS SETOF INTEGER AS $$
      DECLARE
      	r histogram_result;
      BEGIN
      	FOREACH r IN ARRAY h LOOP
          IF r.bucket IS NULL THEN
            CONTINUE;
          END IF;

      		RETURN QUERY VALUES (r.count);
      	END loop;
      END;
      $$ LANGUAGE plpgsql;

      CREATE OR REPLACE FUNCTION histogram_range(h histogram_result[])
      RETURNS SETOF FLOATRANGE AS $$
      DECLARE
      	r histogram_result;
      BEGIN
      	FOREACH r IN ARRAY h LOOP
          IF r.bucket IS NULL THEN
            CONTINUE;
          END IF;

      		RETURN QUERY VALUES (r.range);
      	END loop;
      END;
      $$ LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION histogram_bucket(h histogram_result[])
      RETURNS SETOF INTEGER AS $$
      DECLARE
      	r histogram_result;
      BEGIN
      	FOREACH r IN ARRAY h LOOP
          IF r.bucket IS NULL THEN
      			CONTINUE;
      		END IF;

      		RETURN QUERY VALUES (r.bucket);
      	END loop;
      END;
      $$ LANGUAGE plpgsql;
    EOF
  end
end
