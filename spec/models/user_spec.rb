require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
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
  describe '#set_full_name' do
    it 'sets the full_name' do
      expect(create(:user).full_name).to_not be_empty
    end
  end

  describe '#setup_new_user' do
    it 'sets the default role of trial' do
      expect(build(:user).role).to eq 'trial'
    end

    it 'sets trial_ends_at' do
      expect(build(:user).trial_ends_at).to be_present
    end
  end

  # Methods
  describe '#subscribed?' do
    it 'returns false for users not subscribed' do
      expect(create(:user).subscribed?).to eq false
    end

    it 'returns true for users subscribed' do
      expect(create(:user, stripe_subscription_id: 'asdf').subscribed?).to eq true
    end
  end
end
