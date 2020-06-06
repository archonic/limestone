# frozen_string_literal: true

# This model is not meant to sync with Stripe -
# just to hold the unique stripe_id as a convenience for retrieval.
class Product < ApplicationRecord
  include CurrencyHelper
  attr_accessor :interval, :currency
  validates :name, presence: true
  validates :amount, presence: true
  has_many :users, dependent: :nullify
  before_create :create_product_on_stripe

  scope :active, -> { where(active: true) }

  include ActionView::Helpers::NumberHelper

  def cost
    formatted_amount(amount, currency)
  end

  # TODO Just an example, you'll want something more dependable
  def pro?
    name == "Pro"
  end

  private
    def create_product_on_stripe
      # stripe_id is populated by factory in tests
      CreateProductService.new(self).call unless Rails.env.test?
    end
end
