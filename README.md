# Limestone
[ ![Codeship Status for archonic/limestone](https://app.codeship.com/projects/0e5987c0-e048-0135-9d79-3ee50941199c/status?branch=master)](https://app.codeship.com/projects/266527)

Limestone is a boilerplate SaaS app built with Rails 5 and allows for an opinionated integration with NPM using webpacker. The opinions of this boilerplate stop short of choosing a front-end framework like [React](https://facebook.github.io/react/) or [Vue](https://vuejs.org/), so you can use what you like. This is a work in progress.

## The Stack
The gemset has been chosen to be modern, performant, and take care of a number of business concerns common to SaaS.
* Administrate
* Bootstrap 4
* CoffeeScript
* Devise
* Discard
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
* Trial upon registration without credit card.
* Subscription management. Card update form and cancel account button.
* Emails for welcome, billing updated, invoice paid, invoice failed and trial expiring.
* Direct uploading to S3 with ActiveStorage. Lazy transform for resizing. Demonstrated with user avatars.
* Icon helper for avatars with fallback to circle with user initials.
* Administrate dashboard lets you CRUD records (ex: users). Easy to add more and customize as you like. Visit /admin/.
* Impersonate users through administrate dashboard.
* Mail sends through Sidekiq. Demonstrated with Devise mailing.
* Opinionated search integration using Elasticsearch via Searchkick. Gem is in place but integration is up to you.
* Feature rollout using the rollout gem. Installed but features are up to you.

## Roadmap
* In-browser image cropping using jcrop or the likes.
* Example feature which controls if public sign up is available.
* Pretty modals using bootstrap integrated into rails_ujs data-confirm
* Custom error pages.
* Invoice PDF attached to invoice paid email.

## Notes
* RSpec controller tests have been omitted in favour of requests tests.

## Getting Started
* Install [Docker](https://docs.docker.com/engine/installation/)
* Customize .env from .env-example
* run `docker-compose up --build` to create and run the various images, volumes, containers and a network
* run `docker-compose exec website rails db:setup` to create the DB or `docker-compose exec website rails db:reset` if the DB already exists
* run `docker-compose exec website rails db:migrate` to migrate
* run `docker-compose exec website rails db:seed` to create your admin user and Stripe plan(s)
* Visit localhost:3000 and rejoice

### Setting up production
A wiki will be written about this.
