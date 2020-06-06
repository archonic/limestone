# frozen_string_literal: true

require "rails_helper"
require "stripe_mock"

RSpec.describe CreateProductService, type: :service do
  let(:plan) { create(:plan) }
  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    StripeMock.start
  end
  after do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test"))
    StripeMock.stop
  end

  describe "#call" do
    it "creates the plan" do
      expect(Stripe::Product).to receive(:create).once
      CreateProductService.new(plan)
    end
  end
end
