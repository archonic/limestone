# frozen_string_literal: true

require "administrate/base_dashboard"

class InvoiceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    user: Field::BelongsTo,
    stripe_id: Field::String,
    amount: Field::Number,
    currency: Field::String,
    card_last4: Field::Number,
    card_type: Field::String,
    card_exp_month: Field::Number,
    card_exp_year: Field::Number,
    number: Field::String,
    paid_at: Field::DateTime,
    lines: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    id
    user
    stripe_id
    amount
    currency
    card_type
    card_last4
    card_exp_month
    card_exp_year
    number
    paid_at
    created_at
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    id
    user
    stripe_id
    amount
    currency
    card_type
    card_last4
    card_exp_month
    card_exp_year
    number
    paid_at
    lines
    created_at
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    # Nada! These come from Stripe. No edits allowed!
  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end
