require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(create(:user)).to be_valid
  end

  # Validations
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }

  # Callbacks
  describe '#set_full_name' do
    it 'sets the full_name' do
      expect(create(:user).full_name).to_not be_empty
    end
  end

  it 'sets the default role of trial' do
    expect(create(:user).role).to eq 'trial'
  end

  # Methods
  describe '#subscribed?' do
    it 'returns false for users not subscribed' do
      expect(create(:user).subscribed?).to eq false
    end

    it 'returns true for users subscribed' do
      expect(create(:user_subscribed).subscribed?).to eq true
    end
  end
end
