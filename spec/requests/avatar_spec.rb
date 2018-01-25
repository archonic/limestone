require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe AvatarsController, type: :request do
  let(:user) { create(:user, :user) }
  let(:file) { fixture_file_upload("#{fixture_path}/files/money_sloth.png") }


  describe '#update' do
    subject do
      patch avatars_path, params: { user: { avatar: file } }
      response
    end

    context 'as some rando' do
      it 'responds with unauthorized' do
        # Wish this worked
        # expect(controller).to raise_error(Pundit::NotAuthorizedError)
        expect(subject).to have_http_status(:redirect)
        expect(flash[:alert]).to match 'Access denied'
      end
    end

    context 'as authenticated user' do
      before { sign_in user }

      it 'creates avatar for user' do
        expect(subject).to have_http_status(:redirect)
        expect(flash[:notice]).to match 'Avatar updated'
        expect(user.avatar.variant(:xs).blob.filename.to_s).to eq file.original_filename
      end
    end
  end

  describe '#destroy' do
    before { sign_in user }
    subject do
      delete avatar_path
      response
    end

    it 'removes the avatar' do
      user.avatar.should_receive(:purge).once
      expect(subject).to have_http_status(:redirect)
      expect(flash[:notice]).to match 'Avatar deleted'
    end
  end
end
