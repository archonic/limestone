require 'rails_helper'
require 'stripe_mock'

RSpec.describe CreatePlanService, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:plan) { create(:plan) }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#call' do
    it 'creates the plan' do
      expect(Stripe::Plan).to receive(:create).once
      CreatePlanService.new(plan)
    end
  end
end
