require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid whitout a role' do
      user = build(:user, role: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:stores).dependent(:destroy) }

    it 'destroys associated stores on discard' do
      user = create(:user, role: :seller)
      store = create(:store, user:)

      expect { user.discard }.to change { store.reload.discarded? }.from(false).to(true)
    end
  end

  describe 'callbacks' do
    it 'discard associated stores after user discard' do
      user = create(:user, role: :seller)
      store = create(:store, user:)

      user.discard
      expect(store.reload).to be_discarded
    end
  end

  describe 'enums' do
    it 'defines roles' do
      expect(User.roles.keys).to include('admin', 'seller', 'buyer')
    end
  end

  describe 'token_for' do
    it 'generates a valid JWT token' do
      user = create(:user)
      token = User.token_for(user)
      decoded = JWT.decode(token, Rails.application.credentials.jwt[:decode], true, algorithm: 'HS256')
      expect(decoded[0]['id']).to eq(user.id)
    end

    it 'raises an error for expired token' do
      user = create(:user)
      token = User.token_for(user)
      travel_to 2.hours.from_now do
        expect { User.from_token(token) }.to raise_error(User::InvalidToken)
      end
    end
  end
end
