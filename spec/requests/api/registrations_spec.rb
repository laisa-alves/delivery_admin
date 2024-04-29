require 'rails_helper'

RSpec.describe "registrations", type: :request do
  let(:credential) {
    Credential.create_access(:buyer)
  }

  describe "POST /new" do
    it "creates a buyer user" do
      post(
        create_registration_url,
        headers: {
          "Accept" => "application/json",
          "X-API-KEY" => credential.key
        },
        params: {
          user: {
            email: "buyer@example.com",
            password: "123456",
            password_confirmation: "123456",
          }
        }
      )
      user = User.find_by(email: "buyer@example.com")
      expect(response.successful?).to eq true
      expect(user.buyer?).to eq true
    end
  end

  describe "POST /new" do
    it "fails when trying to create admin users" do
      post(
        create_registration_url,
        headers: {"Accept" => "application/json"},
        params: {
          user: {
            email: "admin@example.com",
            password: "123456",
            password_confirmation: "123456",
            role: :admin
          }
        }
      )
      expect(response.unprocessable?).to eq true
    end
  end

  describe "POST /sign_in" do
    before do
      User.create!(
        email: "seller@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :seller
      )
    end

    it "prevents users with roles different from credentials to sign in" do
      post(
        "/sign_in",
        headers: {
          "Accept" => "application/json",
          "X-API-KEY" => credential.key
        },
        params: {
          signin: {email: "seller@example.com", password: "123456"}
        }
      )
      expect(response).to be_unauthorized
    end
  end
end
