# Limestone
[ ![Codeship Status for archonic/limestone](https://app.codeship.com/projects/0e5987c0-e048-0135-9d79-3ee50941199c/status?branch=master)](https://app.codeship.com/projects/266527)

Limestone is a boilerplate SaaS app built with Rails 5.2 and has an opinionated integration with NPM using [Webpacker](https://github.com/rails/webpacker) and [Stimulus](https://stimulusjs.org/).

Limestone assumes you want each user to pay for access to your SaaS. If you instead want users to belong to accounts and have billing scopes to accounts, try [Limestone Accounts](https://github.com/archonic/limestone-accounts).

## The Stack
The [gemset](https://github.com/archonic/limestone-accounts/blob/master/Gemfile) has been chosen to be modern, performant, and take care of a number of business concerns common to SaaS.

## Features
* Free trial begins upon registration without credit card. Number of days is configurable with ENV var.
* Subscription management. Card update form and cancel account button.
* Emails for welcome, billing updated, invoice paid, invoice failed and trial expiring. All except welcome are controlled by Stripe webhooks.
* Invoice PDF attached to invoice paid email.
* Mail sends through Sidekiq with deliver_later. Devise mailing also configured for Sidekiq dispatch.
* Direct uploading to S3 with ActiveStorage. Lazy transform for resizing. Demonstrated with user avatars.
* Icon helper for user avatars with fallback to circle with user initials. Icon helper for [Font Awesome 4.7](https://fontawesome.com/v4.7.0/icons/) icons.
* Administrate dashboard lets you CRUD records (ex: users). Easy to add more and customize as you like. Visit /admin/.
* Impersonate users through administrate dashboard.
* Pretty modals using bootstrap integrated into rails_ujs data-confirm. Demonstrated with cancel account button.
* Banner with a link to billing page users that are past due.
* Opinionated search integration using Elasticsearch via Searchkick. Gem is in place but integration is up to you.
* Feature control using the flipper gem. Demonstrated with public_registration.
* 86% RSpec test coverage.

## Roadmap
* In-browser image cropping using jcrop or the likes.
* Custom error pages.

## Notes
* RSpec controller tests have been omitted in favour of requests tests.
* You can run tests locally with `docker-compose run web rspec`
* Because this is a boilerplate, there are no migrations. Rely on schema.rb and use `rails db:setup` to create the db and seed.

## Getting Started
* Install [Docker](https://docs.docker.com/engine/installation/)
* Customize .env from .env-example
* run `docker-compose run webpack yarn install --pure-lockfile` to install all node modules. See issue #3 about this.
* run `docker-compose up --build` to create and run the various images, volumes, containers and a network
* run `docker-compose exec web rails db:setup` to create DB, load schema and seed. Seeding will also create your plan(s) in Stripe.
* Visit localhost:3000 and rejoice
* See more about [development with Docker](https://github.com/archonic/limestone/wiki/Development-with-Docker)

### Bonus points
* Login as the admin user that was created (from .env)
* Visit /admin/flipper
* Create the feature `public_registration` as a boolean and enable it. Now anyone can register :clap:

### Setting up production
A wiki will be written about this. Need to learn more about Kubernetes. Feel free to help out here if you're familiar with Docker/Kubernetes.
