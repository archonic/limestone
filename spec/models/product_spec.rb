# frozen_string_literal: true

require "rails_helper"

RSpec.describe Product, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:product)).to be_valid
    end
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
