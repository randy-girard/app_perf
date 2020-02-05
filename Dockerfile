FROM ruby:2.6.5-alpine

LABEL maintainer="Randy Girard <rgirard59@yahoo.com>"

ENV APK_PACKAGES "git build-base supervisor tzdata curl-dev nodejs yarn postgresql-dev postgresql-client sqlite-dev"
# ENV VIRTUAL_APK_PACKAGES ""
# ENV APK_REMOVE_PACKAGES ""

# RUN apk update && apk add --no-cache $APK_PACKAGES --virtual $VIRTUAL_APK_PACKAGES && apk del $APK_REMOVE_PACKAGES
RUN apk update && apk add --no-cache $APK_PACKAGES

# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH
ONBUILD ADD . $INSTALL_PATH

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --jobs 20 --retry 5 --without development test --deployment --quiet && \
      gem install app_perf_agent && yarn install

COPY . .

ENV DATABASE_URL postgres://app_perf:password@postgres:5432/app_perf?encoding=utf8&pool=5&timeout=5000

RUN RAILS_ENV=production SECRET_KEY_BASE=foo bundle exec rake assets:precompile

# Available (and reused) args
# Use --build-arg PORT=5000 to use another app default port
ARG PORT=5000
EXPOSE $PORT

# The default command that gets ran will be to start the puma server and webpack.
CMD ["bundle", "exec", "rails", "s"]

# Metadata
LABEL org.label-schema.vendor="App Perf" \
      org.label-schema.url="https://github.com/randy-girard/app_perf" \
      org.label-schema.name="AppPerf" \
      org.label-schema.description="Open source application performance monitoring tool" \
      org.label-schema.version="v0.0.1" \
      org.label-schema.docker.schema-version="1.0"
