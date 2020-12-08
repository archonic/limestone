# frozen_string_literal: true

# NOTE This model is not meant to sync with Stripe -
# just to hold the unique stripe_id as a convenience for retrieval.
class Plan < ApplicationRecord
  include CurrencyHelper
  belongs_to :product

  validates :name, presence: true
  validates :amount, presence: true
  validates :currency, presence: true
  validates :interval, presence: true

  scope :active, -> { where(active: true) }

  def cost
    formatted_amount(amount, currency)
  end
end
