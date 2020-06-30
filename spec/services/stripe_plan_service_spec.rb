# frozen_string_literal: true

require "rails_helper"

RSpec.describe StripePlanService, type: :service do
  let(:product) { create(:product) }
  let(:plan) { create(:plan, product: product) }

  describe "#create" do
    context "with existing stripe_id" do
      it "avoids contacting Stripe" do
        expect(Stripe::Plan).to_not receive(:create)
        StripePlanService.new(plan).create
      end
    end
    context "without existing stripe_id" do
      before { plan.update(stripe_id: nil) }
      it "creates the product" do
        expect(Stripe::Plan).to receive(:create).once
        StripePlanService.new(plan).create
      end
    end
  end
end
