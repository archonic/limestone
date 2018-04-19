# frozen_string_literal: true

require "rails_helper"

describe IconHelper do
  let(:user) { create(:user) }

  describe "avatar" do
    it "defaults to small" do
      expect(avatar(user)).to match ";s=#{IconHelper::AVATAR_SIZES[:sm]}"
    end

    it "returns avatar" do
      expect(avatar(user)).to match "circular-icon sm avatar-text"
    end

    it "has text backup" do
      expect(avatar(user)).to match user.name.initials
    end
  end

  describe 'icon' do
    it 'defaults to small' do
      expect(icon(:beer)).to match "font-size: #{IconHelper::AVATAR_SIZES[:sm]}px"
    end

    it 'returns a font awesome icon' do
      expect(icon(:beer)).to match "fa fa-beer"
    end
  end
end
