SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: floatrange; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE floatrange AS RANGE (
    subtype = double precision,
    subtype_diff = float8mi
);


--
-- Name: histogram_result; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE histogram_result AS (
	count integer,
	bucket integer,
	range floatrange
);


--
-- Name: hist_sfunc(histogram_result[], double precision, double precision, double precision, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hist_sfunc(state histogram_result[], val double precision, min double precision, max double precision, nbuckets integer) RETURNS histogram_result[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
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
      $$;


--
-- Name: histobar(double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION histobar(v double precision, tick_size double precision) RETURNS text
    LANGUAGE sql
    AS $$
      	SELECT repeat('=', (v * tick_size)::integer);
      $$;


--
-- Name: histogram_bucket(histogram_result[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION histogram_bucket(h histogram_result[]) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
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
      $$;


--
-- Name: histogram_count(histogram_result[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION histogram_count(h histogram_result[]) RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
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
      $$;


--
-- Name: histogram_range(histogram_result[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION histogram_range(h histogram_result[]) RETURNS SETOF floatrange
    LANGUAGE plpgsql
    AS $$
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
      $$;


--
-- Name: show_histogram(histogram_result[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION show_histogram(h histogram_result[]) RETURNS TABLE(bucket integer, range floatrange, count integer, bar text, cumbar text, cumsum integer, cumpct numeric)
    LANGUAGE plpgsql
    AS $$
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
      $$;


--
-- Name: histogram(double precision, double precision, double precision, integer); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE histogram(double precision, double precision, double precision, integer) (
    SFUNC = hist_sfunc,
    STYPE = histogram_result[]
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE applications (
    id integer NOT NULL,
    user_id integer,
    name character varying,
    license_key character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE applications_id_seq OWNED BY applications.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: backtraces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE backtraces (
    id integer NOT NULL,
    backtraceable_type character varying,
    backtraceable_id character varying,
    backtrace text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: backtraces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE backtraces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: backtraces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE backtraces_id_seq OWNED BY backtraces.id;


--
-- Name: database_calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE database_calls (
    id integer NOT NULL,
    application_id integer,
    host_id integer,
    database_type_id integer,
    layer_id integer,
    span_id character varying,
    statement character varying,
    "timestamp" timestamp without time zone,
    duration double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: database_calls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE database_calls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: database_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE database_calls_id_seq OWNED BY database_calls.id;


--
-- Name: database_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE database_types (
    id integer NOT NULL,
    application_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: database_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE database_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: database_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE database_types_id_seq OWNED BY database_types.id;


--
-- Name: error_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE error_data (
    id integer NOT NULL,
    application_id integer,
    host_id integer,
    error_message_id integer,
    transaction_id character varying,
    message character varying,
    backtrace text,
    "timestamp" timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source text,
    span_id character varying
);


--
-- Name: error_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE error_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: error_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE error_data_id_seq OWNED BY error_data.id;


--
-- Name: error_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE error_messages (
    id integer NOT NULL,
    application_id integer,
    fingerprint character varying,
    error_class character varying,
    error_message character varying,
    last_error_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: error_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE error_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: error_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE error_messages_id_seq OWNED BY error_messages.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events (
    id integer NOT NULL,
    type character varying,
    application_id integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    title character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hosts (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hosts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hosts_id_seq OWNED BY hosts.id;


--
-- Name: layers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE layers (
    id integer NOT NULL,
    application_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: layers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE layers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: layers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE layers_id_seq OWNED BY layers.id;


--
-- Name: log_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE log_entries (
    id integer NOT NULL,
    span_id character varying,
    event character varying,
    "timestamp" timestamp without time zone,
    fields text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: log_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_entries_id_seq OWNED BY log_entries.id;


--
-- Name: metric_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE metric_data (
    id integer NOT NULL,
    host_id integer,
    metric_id integer,
    "timestamp" timestamp without time zone,
    value double precision,
    tags jsonb DEFAULT '"{}"'::jsonb
);


--
-- Name: metric_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metric_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metric_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metric_data_id_seq OWNED BY metric_data.id;


--
-- Name: metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE metrics (
    id integer NOT NULL,
    application_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metrics_id_seq OWNED BY metrics.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: spans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE spans (
    application_id integer,
    host_id integer,
    layer_id integer,
    name character varying,
    "timestamp" timestamp without time zone,
    duration double precision,
    exclusive_duration double precision,
    trace_key character varying,
    uuid character varying,
    payload jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id character varying,
    operation_name character varying,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: traces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE traces (
    id integer NOT NULL,
    application_id integer,
    host_id integer,
    trace_key character varying,
    "timestamp" timestamp without time zone,
    duration double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: traces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE traces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: traces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE traces_id_seq OWNED BY traces.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying,
    license_key character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_type character varying,
    invited_by_id integer,
    invitations_count integer DEFAULT 0
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY applications ALTER COLUMN id SET DEFAULT nextval('applications_id_seq'::regclass);


--
-- Name: backtraces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY backtraces ALTER COLUMN id SET DEFAULT nextval('backtraces_id_seq'::regclass);


--
-- Name: database_calls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_calls ALTER COLUMN id SET DEFAULT nextval('database_calls_id_seq'::regclass);


--
-- Name: database_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_types ALTER COLUMN id SET DEFAULT nextval('database_types_id_seq'::regclass);


--
-- Name: error_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_data ALTER COLUMN id SET DEFAULT nextval('error_data_id_seq'::regclass);


--
-- Name: error_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_messages ALTER COLUMN id SET DEFAULT nextval('error_messages_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: hosts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hosts ALTER COLUMN id SET DEFAULT nextval('hosts_id_seq'::regclass);


--
-- Name: layers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY layers ALTER COLUMN id SET DEFAULT nextval('layers_id_seq'::regclass);


--
-- Name: log_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_entries ALTER COLUMN id SET DEFAULT nextval('log_entries_id_seq'::regclass);


--
-- Name: metric_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metric_data ALTER COLUMN id SET DEFAULT nextval('metric_data_id_seq'::regclass);


--
-- Name: metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY metrics ALTER COLUMN id SET DEFAULT nextval('metrics_id_seq'::regclass);


--
-- Name: traces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY traces ALTER COLUMN id SET DEFAULT nextval('traces_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: backtraces backtraces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY backtraces
    ADD CONSTRAINT backtraces_pkey PRIMARY KEY (id);


--
-- Name: database_calls database_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_calls
    ADD CONSTRAINT database_calls_pkey PRIMARY KEY (id);


--
-- Name: database_types database_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_types
    ADD CONSTRAINT database_types_pkey PRIMARY KEY (id);


--
-- Name: error_data error_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_data
    ADD CONSTRAINT error_data_pkey PRIMARY KEY (id);


--
-- Name: error_messages error_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_messages
    ADD CONSTRAINT error_messages_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: layers layers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY layers
    ADD CONSTRAINT layers_pkey PRIMARY KEY (id);


--
-- Name: log_entries log_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_entries
    ADD CONSTRAINT log_entries_pkey PRIMARY KEY (id);


--
-- Name: metric_data metric_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY metric_data
    ADD CONSTRAINT metric_data_pkey PRIMARY KEY (id);


--
-- Name: metrics metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY metrics
    ADD CONSTRAINT metrics_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: spans spans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY spans
    ADD CONSTRAINT spans_pkey PRIMARY KEY (id);


--
-- Name: traces traces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY traces
    ADD CONSTRAINT traces_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_metric_data_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_metric_data_tags ON metric_data USING gin (tags jsonb_path_ops);


--
-- Name: idx_spans_payload; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_spans_payload ON spans USING gin (payload jsonb_path_ops);


--
-- Name: index_applications_on_name_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_applications_on_name_and_user_id ON applications USING btree (name, user_id);


--
-- Name: index_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_applications_on_user_id ON applications USING btree (user_id);


--
-- Name: index_backtraces_on_backtraceable_type_and_backtraceable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_backtraces_on_backtraceable_type_and_backtraceable_id ON backtraces USING btree (backtraceable_type, backtraceable_id);


--
-- Name: index_database_calls_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_database_calls_on_application_id ON database_calls USING btree (application_id);


--
-- Name: index_database_calls_on_database_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_database_calls_on_database_type_id ON database_calls USING btree (database_type_id);


--
-- Name: index_database_calls_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_database_calls_on_host_id ON database_calls USING btree (host_id);


--
-- Name: index_database_calls_on_layer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_database_calls_on_layer_id ON database_calls USING btree (layer_id);


--
-- Name: index_database_calls_on_span_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_database_calls_on_span_id ON database_calls USING btree (span_id);


--
-- Name: index_database_calls_on_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_database_calls_on_timestamp ON database_calls USING btree ("timestamp");


--
-- Name: index_database_types_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_database_types_on_application_id ON database_types USING btree (application_id);


--
-- Name: index_error_data_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_error_data_on_application_id ON error_data USING btree (application_id);


--
-- Name: index_error_data_on_error_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_error_data_on_error_message_id ON error_data USING btree (error_message_id);


--
-- Name: index_error_data_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_error_data_on_host_id ON error_data USING btree (host_id);


--
-- Name: index_error_messages_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_error_messages_on_application_id ON error_messages USING btree (application_id);


--
-- Name: index_events_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_application_id ON events USING btree (application_id);


--
-- Name: index_layers_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layers_on_application_id ON layers USING btree (application_id);


--
-- Name: index_layers_on_name_and_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layers_on_name_and_application_id ON layers USING btree (name, application_id);


--
-- Name: index_log_entries_on_span_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_entries_on_span_id ON log_entries USING btree (span_id);


--
-- Name: index_metric_data_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_metric_data_on_host_id ON metric_data USING btree (host_id);


--
-- Name: index_metric_data_on_metric_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_metric_data_on_metric_id ON metric_data USING btree (metric_id);


--
-- Name: index_metrics_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_metrics_on_application_id ON metrics USING btree (application_id);


--
-- Name: index_spans_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spans_on_application_id ON spans USING btree (application_id);


--
-- Name: index_spans_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spans_on_host_id ON spans USING btree (host_id);


--
-- Name: index_spans_on_layer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spans_on_layer_id ON spans USING btree (layer_id);


--
-- Name: index_spans_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spans_on_parent_id ON spans USING btree (parent_id);


--
-- Name: index_spans_on_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spans_on_timestamp ON spans USING btree ("timestamp");


--
-- Name: index_spans_on_trace_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spans_on_trace_key ON spans USING btree (trace_key);


--
-- Name: index_traces_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_traces_on_application_id ON traces USING btree (application_id);


--
-- Name: index_traces_on_host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_traces_on_host_id ON traces USING btree (host_id);


--
-- Name: index_traces_on_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_traces_on_timestamp ON traces USING btree ("timestamp");


--
-- Name: index_traces_on_trace_key_and_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_traces_on_trace_key_and_application_id ON traces USING btree (trace_key, application_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON users USING btree (invited_by_id);


--
-- Name: index_users_on_invited_by_type_and_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_type_and_invited_by_id ON users USING btree (invited_by_type, invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: metrics fk_rails_011a3e569f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY metrics
    ADD CONSTRAINT fk_rails_011a3e569f FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: database_calls fk_rails_1025ac6d1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_calls
    ADD CONSTRAINT fk_rails_1025ac6d1a FOREIGN KEY (layer_id) REFERENCES layers(id);


--
-- Name: spans fk_rails_238b63daa9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY spans
    ADD CONSTRAINT fk_rails_238b63daa9 FOREIGN KEY (host_id) REFERENCES hosts(id);


--
-- Name: error_messages fk_rails_384d6fa11a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_messages
    ADD CONSTRAINT fk_rails_384d6fa11a FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: traces fk_rails_3f4665e0b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY traces
    ADD CONSTRAINT fk_rails_3f4665e0b5 FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: database_calls fk_rails_40b3ccef67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_calls
    ADD CONSTRAINT fk_rails_40b3ccef67 FOREIGN KEY (host_id) REFERENCES hosts(id);


--
-- Name: database_types fk_rails_40cfd232fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_types
    ADD CONSTRAINT fk_rails_40cfd232fc FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: events fk_rails_5502771cf0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_rails_5502771cf0 FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: traces fk_rails_6c5cd9a577; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY traces
    ADD CONSTRAINT fk_rails_6c5cd9a577 FOREIGN KEY (host_id) REFERENCES hosts(id);


--
-- Name: error_data fk_rails_6f4ca3da14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_data
    ADD CONSTRAINT fk_rails_6f4ca3da14 FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: applications fk_rails_703c720730; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT fk_rails_703c720730 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: layers fk_rails_7347a524b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY layers
    ADD CONSTRAINT fk_rails_7347a524b6 FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: spans fk_rails_75ce7a410c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY spans
    ADD CONSTRAINT fk_rails_75ce7a410c FOREIGN KEY (layer_id) REFERENCES layers(id);


--
-- Name: spans fk_rails_9516b75a98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY spans
    ADD CONSTRAINT fk_rails_9516b75a98 FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: metric_data fk_rails_9fc5ea3242; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY metric_data
    ADD CONSTRAINT fk_rails_9fc5ea3242 FOREIGN KEY (host_id) REFERENCES hosts(id);


--
-- Name: metric_data fk_rails_b2e9a5a928; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY metric_data
    ADD CONSTRAINT fk_rails_b2e9a5a928 FOREIGN KEY (metric_id) REFERENCES metrics(id);


--
-- Name: error_data fk_rails_b51fd68f43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_data
    ADD CONSTRAINT fk_rails_b51fd68f43 FOREIGN KEY (host_id) REFERENCES hosts(id);


--
-- Name: error_data fk_rails_d74ab25774; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_data
    ADD CONSTRAINT fk_rails_d74ab25774 FOREIGN KEY (error_message_id) REFERENCES error_messages(id);


--
-- Name: database_calls fk_rails_e1ffc54547; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_calls
    ADD CONSTRAINT fk_rails_e1ffc54547 FOREIGN KEY (application_id) REFERENCES applications(id);


--
-- Name: database_calls fk_rails_e4c11371a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_calls
    ADD CONSTRAINT fk_rails_e4c11371a0 FOREIGN KEY (database_type_id) REFERENCES database_types(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160428204600'),
('20160428204603'),
('20160507124206'),
('20160515180739'),
('20160515182837'),
('20160519121226'),
('20160519121315'),
('20160519131250'),
('20160519131253'),
('20160519131260'),
('20160519134740'),
('20161230191409'),
('20161231022752'),
('20170106142559'),
('20170108135011'),
('20170111003940'),
('20170427234422'),
('20170428004655'),
('20170428145810'),
('20170428155739'),
('20170428180924'),
('20170726010744'),
('20170726123049'),
('20170727161615'),
('20170727172500'),
('20170727175217'),
('20170728002115'),
('20170728002503'),
('20170803133120'),
('20170803194431'),
('20170803194915'),
('20170803200634'),
('20170812161507'),
('20170812162234'),
('20170813124637'),
('20171025163818'),
('20171027003948'),
('20171027010303'),
('20171028020823'),
('20171028131934'),
('20171101185138'),
('20171106004939'),
('20171106015034'),
('20180530143857'),
('20180530175949'),
('20180531135158'),
('20181005151705'),
('20190306123959');


