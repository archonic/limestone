FROM ruby:2.5-alpine

RUN apk update && apk add build-base nodejs python2 postgresql-dev --no-cache yarn

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs

COPY package.json yarn.lock ./
RUN yarn --pure-lockfile

COPY . .

# Replace this with yourself
LABEL maintainer="Joshua Flark <joshuajmark@gmail.com>"

CMD puma -C config/puma.rb
