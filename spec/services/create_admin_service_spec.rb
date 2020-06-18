# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateAdminService, type: :service do
  describe "#call" do
    before { create(:product) }

    it "creates the admin" do
      expect(User.count).to eq 0
      CreateAdminService.call
      expect(User.count).to eq 1
      expect(User.first.admin?).to be true
    end
  end
end
