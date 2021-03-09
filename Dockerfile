FROM ruby:2.7.2-alpine3.11

RUN apk update && apk add --update \
  build-base \
  curl \
  git \
  nodejs \
  npm \
  python2 \
  postgresql-dev \
  postgresql-client \
  graphicsmagick &&\
  apk add -u yarn

RUN mkdir /app
WORKDIR /app

# NOTE This must match "BUNDLED WITH" in Gemfile.lock
RUN gem install bundler:2.2.4

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN set -ex; \
  yarn install --frozen-lockfile --production; \
  yarn cache clean;

# Make busybox and pry work nicely for large output
ENV PAGER='more'
ENV BUNDLE_FORCE_RUBY_PLATFORM=1
ENV RAILS_ENV='production'

# node-scss build issue https://github.com/yarnpkg/yarn/issues/4867#issuecomment-412463845
RUN npm rebuild

COPY . .

# Precompile assets into image
# We need the server to be able to start to run this step
ENV SECRET_KEY_BASE bunchofgarbage
ENV DATABASE_URL postgresql://just@start:5432/theserver
ENV REDIS_BASE_URL redis://please:6379/0
RUN rails assets:precompile

# Cleanup
RUN rm -rf /var/cache/apk/*

CMD ["rails", "server", "-b", "0.0.0.0"]
