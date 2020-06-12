# Limestone
[![<archonic>](https://circleci.com/gh/archonic/limestone.svg?style=svg)](https://circleci.com/gh/archonic/workflows/limestone/tree/master)

Limestone is a boilerplate SaaS app built with Rails 6 on Ruby 2.7.1 and has an opinionated integration with NPM using [Webpacker](https://github.com/rails/webpacker) and [Stimulus](https://stimulusjs.org/).

Limestone assumes you want each user to pay for access to your SaaS. If you instead want users to belong to accounts and have billing scoped to accounts, try [Limestone Accounts](https://github.com/archonic/limestone-accounts).

## Versions
Versioning in this repo in intended to maintain and modernize the boilerplate. New versions are not intended to update existing forks, although looking through the commits serve as a good upgrade resource.

v0.1 is Rails 5.2  
v0.2+ is Rails 6

See more in the [changelog](https://github.com/archonic/limestone/blob/master/CHANGELOG.md).

## The Stack
The [gemset](https://github.com/archonic/limestone/blob/master/Gemfile) has been chosen to be modern, performant, and take care of a number of business concerns common to SaaS.

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
* Feature control using the [Flipper](https://github.com/jnunemaker/flipper) gem. Demonstrated with the `public_registration` feature.
* 87.85% RSpec test coverage.

## Notes
* RSpec controller tests have been omitted in favour of requests tests.
* You can run tests locally with `docker-compose run web rspec`
* Because this is a boilerplate, there are no migrations. Rely on schema.rb and use `rails db:setup` to create the db and seed.

## Pre-requisites

### Development
* Install [Docker](https://docs.docker.com/engine/installation/) and [Docker Compose](https://docs.docker.com/compose/install/)
* A [Stripe](https://dashboard.stripe.com/register) account and a [Stripe API Key](https://stripe.com/docs/keys).

### Test
* [Codeship](https://codeship.com/) files are in place - just create an account and integrate with your repo. You will need to create your [codeship.aes file](https://documentation.codeship.com/pro/builds-and-configuration/environment-variables/#downloading-your-aes-key), [install jet](https://documentation.codeship.com/pro/jet-cli/installation/) and run `jet encrypt .env .env.encrypted`.
* [CircleCI](https://circleci.com/) files are in place - just create an account and integrate with your repo.
* You could also just run test locally with `docker-compose run web rspec` or `docker-compose exec web rspec` if you've already run `docker-compose up`.

### Production
* A cloud storage account compatible with ActiveStorage (AWS S3 is the default).
* Because Docker is already configured, you probably want a Kubernetes host ([GKE](https://cloud.google.com/kubernetes-engine/), [AWS](https://aws.amazon.com/kubernetes/) or [DigitalOcean](https://www.digitalocean.com/products/kubernetes/)).

## Getting Started
1. Clone this repository to your local system and `cd` into it:
    ```
    git clone https://github.com/archonic/limestone.git
    cd limestone
    ```

2. Make a copy of `.env-example` named `.env`:
    ```
    cp .env-example .env
    ```

3. Update the `.env` file - running the project in development mode requires you change the following:
    - `STRIPE_API_KEY`
    - `STRIPE_PUBLISHABLE_KEY`
    - `STRIPE_SIGNING_SECRET` (This can be something random)

    You probably want to update the `ADMIN_*` environment variables. If you want a different `COMPOSE_PROJECT_NAME` and database name, now is the best time to do that.

4. Run `docker-compose run web yarn install --pure-lockfile` to download images, build your development image and install node_modules. This will take a while.

5. Run `docker-compose up` to run your project and it's dependencies.

5. Once everything is up, run `docker-compose exec web rails db:prepare` to create DB, load schema and seed. Seeding will also create your plan(s) in Stripe.

6. Visit [http://localhost:3000](http://localhost:3000) and rejoice :tada: You can login using the Admin user defined in `.env`

7. See the [Limestone Wiki](https://github.com/archonic/limestone/wiki) more about [development with Docker](https://github.com/archonic/limestone/wiki/Development-with-Docker)

### Enable Public User Registration
1. Visit the `/admin/flipper` page
2. Create a new Feature called `public_registration` enable it. Now anyone can register :clap:

### Setting up production
A wiki will be written about this. Need to learn more about Kubernetes. Feel free to help out here if you're familiar with Docker/Kubernetes.
