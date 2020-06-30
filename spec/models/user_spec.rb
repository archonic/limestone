# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(create(:user)).to be_valid
  end

  # Validations
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { is_expected.to allow_value("email@address.foo").for(:email) }
  it { is_expected.to_not allow_value("email").for(:email) }
  it { is_expected.to_not allow_value("email@domain").for(:email) }
  it { is_expected.to_not allow_value("email@domain.").for(:email) }
  it { is_expected.to_not allow_value("email@domain.a").for(:email) }

  # Callbacks
  describe "#set_name" do
    it "sets the name" do
      expect(create(:user).name).to_not be_empty
    end
  end

  # Flipper
  describe "#flipped_id" do
    let(:user) { create(:user) }
    it "returns namespaced id" do
      expect(user.flipper_id).to match "User:#{user.id}"
    end
  end
end
