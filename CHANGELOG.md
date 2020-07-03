# Changelog

## v0.3
* Security updates
* Updated readme with better Getting Started instructions.
* Upgraded to Ruby 2.7.1 and fixed version pinning.
* Integrated Pay gem for all subscription management :tada:
* Removed user `role` enum
* Removed invoices (will rely on Stripe for invoice generation)
* Converted Coffeescript to JS and removed Coffeescript.
* Updated Webpacker and Moved rails-ujs and actioncable to webpack.
* Issues with administrate fixed by using a fork and overriding templates.
* curl installed in dockerfile.
* Updated Devise.
* Configured Devise confirmable module. All emails in all apps should be confirmed.
* Upgraded Sidekiq to 6.1
* letter_opener and letter_opener_web installed and configured. Visit /admin/letter_opener to view sent mail in the development environment.

## v0.2
* Rails updated to 6.0.2.1
* Upgraded webpacker to 4.2.2
* Ruby upgraded to 2.7.0
* Docker Compose simplified. Cable and webpack services removed because `rails s` handles this. Rails and Sidekiq services now share the same image (faster building, smaller disk footprint).
* Many other gems upgraded

## v0.1
* Everything to date! SaaS boilerplate built on Rails 5.2.
