# frozen_string_literal: true

require "rails_helper"
require "stripe_mock"

RSpec.describe Product, type: :model do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
  end
  after { StripeMock.stop }

  describe "validations" do
    it "has a valid factory" do
      expect(build(:plan)).to be_valid
    end

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:amount) }
  end

  describe "cost" do
    it "returns a human readble amount" do
      expect(build(:plan).cost).to eq "$1,000.00 USD"
    end
  end
end
