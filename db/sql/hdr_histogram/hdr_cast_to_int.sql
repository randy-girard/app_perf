DROP FUNCTION hdr_cast_to_int(histogram jsonb);
CREATE OR REPLACE FUNCTION hdr_cast_to_int(histogram jsonb) RETURNS histogram AS $$
  DECLARE
    input text[];
    counts integer[];
    output histogram;
  BEGIN
    SELECT
      array_agg(ary)::text[]
    INTO
      input
    FROM
      jsonb_array_elements_text($1) AS ary;

    SELECT TRANSLATE(input[4]::jsonb::text, '[]', '{}')::integer[] INTO counts;

    output.minValue := input[1]::integer;
    output.maxValue := input[2]::integer;
    output.significantFigures := input[3]::integer;
    output.counts := counts;

    RETURN output;
  END;
$$ LANGUAGE plpgsql STABLE;
