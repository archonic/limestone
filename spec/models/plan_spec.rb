# frozen_string_literal: true

require "rails_helper"

RSpec.describe Plan, type: :model do
  describe "factory" do
    let(:product) { create(:product) }
    it "has a valid factory" do
      expect(build(:plan, product: product)).to be_valid
    end
  end

  describe "validations" do
    it { should belong_to(:product) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:interval) }
  end

  describe "cost" do
    it "returns a human readble amount" do
      expect(build(:plan).cost).to eq "$9.00 USD"
    end
  end
end
