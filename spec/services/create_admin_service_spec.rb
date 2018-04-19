# frozen_string_literal: true

require "rails_helper"
require "stripe_mock"

RSpec.describe CreateAdminService, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "#call" do
    before { create(:plan) }

    it "creates the admin" do
      expect(User.count).to eq 0
      CreateAdminService.call
      expect(User.count).to eq 1
      expect(User.first.admin?).to be true
    end
  end
end
