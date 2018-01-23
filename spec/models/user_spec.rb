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

  describe '#setup_new_user' do
    it 'sets the default role of trial' do
      expect(build(:user).role).to eq 'trial'
    end

    it 'sets trial_ends_at' do
      expect(build(:user).trial_ends_at).to be_present
    end
  end

  describe 'trial_role?' do
    it 'returns true for trial' do
      expect(build(:user, role: :trial).trial_role?).to be true
    end

    it 'returns false for other roles' do
      expect(build(:user, role: :admin).trial_role?).to be false
    end
  end

  describe 'removed_role?' do
    it 'returns true for removed' do
      expect(build(:user, role: :removed).removed_role?).to be true
    end

    it 'returns false for other roles' do
      expect(build(:user, role: :admin).removed_role?).to be false
    end
  end

  describe 'user_role?' do
    it 'returns true for user' do
      expect(build(:user, role: :user).user_role?).to be true
    end

    it 'returns false for other roles' do
      expect(build(:user, role: :admin).user_role?).to be false
    end
  end

  describe 'trial_expired?' do
    it 'returns false for a valid trial' do
      expect(build(:user, trial_ends_at: 14.days.from_now).trial_expired?).to be false
    end

    it 'returns true for expired trial' do
      expect(build(:user, trial_ends_at: 1.hour.ago).trial_expired?).to be true
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
