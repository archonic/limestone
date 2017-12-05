# Limestone Webpack ![TravisCI](https://travis-ci.org/archonic/limestone.svg?branch=master)

Limestone is a boilerplate SaaS app built with Rails 5 and allows for an opinionated integration with NPM. It uses a webpack pipeline which works with Rails' asset pipeline. The opinions of this boilerplate stop short of choosing a front-end framework like [React](https://facebook.github.io/react/) or [Vue](https://vuejs.org/), so you can use what you like. This is a work in progress.

## The Stack
The gemset has been chosen to be modern, performant, and take care of a number of business concerns common to SaaS.
* Administrate
* Bootstrap 4
* CoffeeScript
* Devise
* HAML
* jQuery
* Postgres
* Pretender
* Pundit
* Rollout
* Rspec (w/ shoulda_matchers, database_cleaner)
* Searchkick
* Shrine
* Sidekiq
* Simple Form
* Stripe
* Turbolinks 5

## Features
* Direct uploading to S3 with Shrine, with progress bar. Image processing for resizing. Demonstrated with user avatars.
* Subscription management. Card update forms.
* Trial upon registration without credit card.
* Administrate dashboard lets you CRUD records (ex: users). Easy to add more and customize as you like. Visit /admin/.
* Impersonate users through administrate dashboard.
* Mail sends through Sidekiq. Demonstrated with Devise mailing.
* Opinionated search integration using Searchkick. Gem is in place but integration is up to you.
* Feature rollout using the rollout gem. Installed but features are up to you.
* Stripe subscription on sign up. Supports free trial without providing card.
* Icon helper for avatars with fallback to circle with user initials.

## Roadmap
* Email PDF receipts after Stripe charges card (using Stripe webhook).
* In-browser image cropping using jcrop or the likes.

## Notes
* RSpec controller tests have been omitted in favour of requests tests.

## Getting Started
* `git clone git@github.com:archonic/limestone.git`
* Customize config/database.yml
* Customize config/secrets.yml from config/secrets-example.yml
* Run `gem install foreman`. This is intentionally left out of the Gemfile.
* `rails db:setup` (running seeds will create the admin user and your Stripe Plan)
* Start servers with `foreman start -f Procfile.dev` and visit localhost:5000

### Setting up production
A wiki will be written about this. Instructions for both Heroku and AWS would be handy.
