FROM ruby:2.6.1-alpine

RUN apk update && apk add build-base nodejs yarn postgresql-dev postgresql-client sqlite-dev tzdata curl-dev git

RUN apk add --no-cache supervisor

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs

RUN gem install app_perf_agent

COPY . .
COPY .env.docker ./.env.development
COPY supervisord.conf /etc/supervisord/conf.d/supervisord.conf

LABEL maintainer="Randy Girard <rgirard59@yahoo.com>"

CMD cd /app &&\
    yarn install &&\
    bundle exec rake assets:precompile &&\
    bundle exec rake db:create &&\
    bundle exec rake db:migrate &&\
    bundle exec rake db:seed &&\
    /bin/sh -c "/usr/bin/supervisord -c /app/supervisord.conf"

EXPOSE 5000
