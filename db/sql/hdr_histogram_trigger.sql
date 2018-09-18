CREATE OR REPLACE FUNCTION set_hdr_histogram_value() RETURNS trigger AS '
BEGIN
  NEW.hdr_histogram := hdr_histogram(hdr_cast_to_int(NEW.histogram));
  RETURN NEW;
END' LANGUAGE 'plpgsql';

CREATE TRIGGER hdr_histogram_trigger
BEFORE INSERT ON metric_data
FOR EACH ROW
EXECUTE PROCEDURE set_hdr_histogram_value();



CREATE OR REPLACE FUNCTION set_hdr_c_histogram_value() RETURNS trigger AS '
BEGIN
  NEW.hdr_histogram := hdr_c_cast_to_hdr(NEW.histogram);
  RETURN NEW;
END' LANGUAGE 'plpgsql';

CREATE TRIGGER hdr_histogram_trigger
BEFORE INSERT ON metric_data
FOR EACH ROW
EXECUTE PROCEDURE set_hdr_c_histogram_value();
