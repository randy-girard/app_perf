FROM ruby:2.3-alpine

RUN apk update && apk add build-base nodejs postgresql-dev sqlite-dev tzdata curl-dev

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs

COPY . .

LABEL maintainer="Randy Girard <rgirard59@yahoo.com>"

CMD bundle exec rails s -p 5000 -b 0.0.0.0
