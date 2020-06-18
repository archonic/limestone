# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateProductService, type: :service do
  let(:product) { create(:product) }

  describe "#call" do
    it "creates the product" do
      expect(Stripe::Product).to receive(:create).once
      CreateProductService.new(product)
    end
  end
end
