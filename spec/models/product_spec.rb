# frozen_string_literal: true

require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:product)).to be_valid
    end

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:amount) }
  end

  describe "cost" do
    it "returns a human readble amount" do
      expect(build(:product).cost).to eq "$1,000.00 USD"
    end
  end
end
