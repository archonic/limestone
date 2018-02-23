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
    let(:user) { build(:user) }
    it 'sets role to basic and trialing to true' do
      expect(user.role).to eq 'basic'
      expect(user.trialing).to eq true
    end

    it 'sets current_period_end' do
      expect(user.current_period_end).to be_present
    end
  end

  # Methods
  describe '#subscribed?' do
    it 'returns false for users not subscribed' do
      expect(create(:user).subscribed?).to be false
    end

    it 'returns false for trial users' do
      expect(create(:user, :trialing).subscribed?).to be false
    end

    it 'returns true for users subscribed' do
      expect(create(:user, :subscribed).subscribed?).to be true
    end
  end

  describe '#trial_expired?' do
    it 'returns false for new trial user' do
      expect(create(:user, :trialing).trial_expired?).to be false
    end

    it 'returns true for expired trial user' do
      expect(create(:user, :expired).trial_expired?).to be true
    end

    it 'returns false for subscribed user even if trial over' do
      expect(create(:user, :subscribed).trial_expired?).to be false
      expect(create(:user, :subscribed, current_period_end: 1.hour.ago).trial_expired?).to be false
    end
  end

  describe '#flipped_id' do
    it 'returns namespaced id' do
      expect(create(:user).flipper_id).to match /User;/
    end
  end
end
