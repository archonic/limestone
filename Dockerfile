FROM ruby:2.5-alpine

RUN apk update && apk add build-base git nodejs python2 postgresql-dev postgresql-client graphicsmagick --no-cache yarn

# Make busybox and pry work nicely for large output
ENV PAGER='more'

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn --pure-lockfile

COPY . .

# Replace this with yourself
LABEL maintainer="Joshua Flark <joshuajmark@gmail.com>"

CMD puma -C config/puma.rb
