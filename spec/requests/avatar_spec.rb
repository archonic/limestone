# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe AvatarsController, type: :request do
  let(:user) { create(:user) }
  let(:file) { fixture_file_upload("#{fixture_path}/files/money_sloth.png") }

  describe "#update" do
    subject do
      patch avatars_path, params: { user: { avatar: file } }
      response
    end

    context "as some rando" do
      it "responds with unauthorized" do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "as authenticated user" do
      before { sign_in user }

      it "creates avatar for user" do
        expect(subject).to have_http_status(:redirect)
        expect(flash[:notice]).to match "Avatar updated"
        expect(user.avatar.variant(resize: "100x100").blob.filename.to_s).to eq file.original_filename
      end
    end
  end

  describe "#destroy" do
    before { sign_in user }
    subject do
      delete avatar_path
      response
    end

    it "removes the avatar" do
      expect(user.avatar).to receive(:purge).once
      expect(subject).to have_http_status(:redirect)
      expect(flash[:notice]).to match "Avatar deleted"
    end
  end
end
