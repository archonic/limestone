# This model is not meant to sync with Stripe -
# just to hold the unique stripe_id as a convenience for retrieval.
class Plan < ApplicationRecord
  attr_accessor :interval, :currency
  validates :name, presence: true
  validates :amount, presence: true
  before_create :create_plan_on_stripe

  private

  def create_plan_on_stripe
    CreatePlanService.new(self).call
  end
end
