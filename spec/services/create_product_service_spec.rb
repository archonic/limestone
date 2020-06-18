# frozen_string_literal: true

require "rails_helper"

RSpec.describe StripeProductService, type: :service do
  let(:product) { create(:product) }

  describe "#call" do
    it "creates the product" do
      expect(Stripe::Product).to receive(:create).once
      StripeProductService.new(product)
    end
  end
end
