# frozen_string_literal: true

require "rails_helper"
require "stripe_mock"

RSpec.describe CreatePlanService, type: :service do
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
      expect(Stripe::Plan).to receive(:create).once
      CreatePlanService.new(plan)
    end
  end
end
