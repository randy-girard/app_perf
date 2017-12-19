## AppPerf (Application Performance Monitoring)

[![Build Status](https://travis-ci.org/randy-girard/app_perf.svg?branch=master)](https://travis-ci.org/randy-girard/app_perf)

Join Slack using this link: https://join.slack.com/t/app-perf/shared_invite/enQtMjg4ODkyOTM1NDQzLTg1MmU5MTlmMmE3MDhjZDBkMDYzNDQyNTIxMjU4OWI2ZjUwOWM2OGYyZjU3YTMyZTNhMTMzMGZhYjFlZTlkMzQ

**More images are at the bottom.**

![Overview](/doc/overview.png?raw=true "Overview")


<b>NOTE: This application is in extremely beginning stages and I am still working out flows and learning the data model. I will be cleaning code up as I go.</b>

This is a application monitoring app. I am trying to build an open source, easy to setup, performance monitoring tool.


### Setup (Localhost)

Setup should be striaghtforward and easy. We use foreman to manage processes. Begin by running the setup script:

```
./bin/setup
```

This should create and setup the database and any other needed services/apps. Then to start everything up, run foreman:

```
bundle exec foreman start
```

### Setup (Docker)

AppPerf supports using Docker and Docker Compose. Just run the following and you should be good to go:

```
docker-compose build
docker-compose up
```

Navigate to http://localhost:5000. This application is setup to report to itself so you can begin seeing information immediatetly!

### Using Other databases

SQLite has some limitation with concurrency in this app, as well as various date functions used for reporting. If you would rather test against postgresql (Mysql to come), you can run the following command to create a local development database running on port 5443 (Must have postgresql installed):
```
./bin/setup_psql
```

**Note: Don't forget to update your `config/database.yml` file.**

## Adding Applications

App Perf will automatically detect new applications that are posting data and display them in the Applications page. From there you can go to each individual application to view the performance metrics.

In order to monitor an application, you have to add the Ruby Agent gem to the Gemfile:

```
gem "app_perf_rpm"
```

Once you have add the gem, Add the following lines to your project (or in an initializer):

```
require 'app_perf_rpm'

AppPerfRpm.configure do |rpm|
  rpm.license_key = "License Key"
  rpm.application_name = "Application Name"
end
```

You can get your license key by visiting the Applications tab and clicking the "New Application" button.

## Adding servers

Install the App Perf Agent gem:
```
gem install app_perf_agent
```

Then run the following command on your server:

```
app_perf_agent --license LICENSE_KEY --host HOST
```

More information is on the Edit Organization page.

## How the data model works

Adding metrics to App Perf is as simple as posting data to the following endpoint:
```
POST http://domain/api/listener/:protocol_version/:license_key
```
Currently the only protocol version supported is 2. License key is generated when you create a new user account. There is a default one that is used for testing in the `.env.development` file.

##### TODO: Add examples of how to submit data.

## Contributing to the App Perf RPM or Agent

Clone the github project at https://github.com/randy-girard/app_perf_rpm or https://github.com/randy-girard/app_perf_agent somewhere locally, then run the following command for the RPM to force bundler to look at that specific path:

```
bundle config local.app_perf_rpm /path/to/local/app_perf_rpm
```

To remove this configuration, run the following command:
```
bundle config --delete local.app_perf_rpm
```

![Trace](/doc/trace.png?raw=true "Traces")

![Database](/doc/database.png?raw=true "Database")

![Host](/doc/hosts.png?raw=true "Hosts")

![Error](/doc/error.png?raw=true "Overview")
