# frozen_string_literal: true

# NOTE This model is not meant to sync with Stripe -
# just to hold the unique stripe_id as a convenience for retrieval.
class Product < ApplicationRecord
  validates :name, presence: true
  has_many :users, dependent: :nullify

  scope :active, -> { where(active: true) }

  # TODO Just an example, you'll want something more dependable
  def pro?
    name == "Pro"
  end
end