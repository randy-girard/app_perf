## AppPerf (Application Performance Monitoring)

![Overview](/doc/overview.png?raw=true "Overview")
![Sample](/doc/sample.png?raw=true "Sample")

<b>NOTE: This application is in extremely beginning stages and I am still working out flows and learning the data model. I will be cleaning code up as I go.</b>

This is a application monitoring app. I am trying to build an open source, easy to setup, performance monitoring tool that will follow this roadmap:

1.  Create the web app/ui to display charts and analytics for analyzing performance using its own Agent.
2.  Extract agent code out into separate gem.
3.  Develop additional agents for other languages, hopefully from open source contribution.
4.  Create ability to import data from other agents, such as NewRelic down the road.
  
  
### Setup

Setup should be striaghtforward and easy. We use foreman to manage processes. Begin by running the setup script:

```
/bin/setup
```
  
This should create and setup the database and any other needed services/apps. Then to start everything up, run foreman:

```
bundle exec foreman start
```

Navigate to http://localhost:9291. This application is setup to report to itself so you can begin seeing information immediatetly!
