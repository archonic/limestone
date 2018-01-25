require 'rails_helper'
require 'stripe_mock'

RSpec.describe CreatePlanService, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#call' do
    context 'with no pre-existing plan' do
      it 'creates the basic plan' do
        Stripe::Plan.should_receive(:create).once
        CreatePlanService.call
      end
    end

    context 'with a pre-existing plan' do
      before { stripe_helper.create_plan(id: 'Basic', amount: 900, trial_period_days: $trial_period_days) }
      it 'does not create basic plan when it already exists' do
        expect(Stripe::Plan).not_to receive(:create)
        CreatePlanService.call
      end
    end
  end
end
