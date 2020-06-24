# frozen_string_literal: true

require "rails_helper"

RSpec.describe StripeProductService, type: :service do
  let(:product) { create(:product) }

  describe "#create" do
    context "with existing stripe_id" do
      it "avoids contacting Stripe" do
        expect(Stripe::Product).to_not receive(:create)
        StripeProductService.new(product).create
      end
    end
    context "without existing stripe_id" do
      before { product.update(stripe_id: nil) }
      it "creates the product" do
        expect(Stripe::Product).to receive(:create).once
        StripeProductService.new(product).create
      end
    end
  end
end
