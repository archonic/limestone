FROM ruby:2.7.1-alpine3.11

RUN apk update && apk add build-base git nodejs python2 postgresql-dev postgresql-client graphicsmagick yarn --no-cache

# Make busybox and pry work nicely for large output
ENV PAGER='more'

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN set -ex; \
  yarn install --frozen-lockfile --production; \
  yarn cache clean;

COPY . .

# Build production assets into image
# Need keys to be set to start server but they don't need to be valid
ENV SECRET_KEY_BASE bunchofgarbage
ENV DATABASE_URL postgresql://just@start:5432/theserver
ENV REDIS_BASE_URL redis://please:6379/0
RUN RAILS_ENV=production bin/bundle exec rake assets:precompile

CMD ["rails", "server", "-b", "0.0.0.0"]
