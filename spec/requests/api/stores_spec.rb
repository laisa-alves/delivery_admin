require "rails_helper"

RSpec.describe "/stores", type: :request do
  let(:user) {
    user = User.new(
      email: "user_01@example.com",
      password: "123456",
      password_confirmation: "123456",
      role: :seller
      )
    user.save!
    user
  }

  let(:credential) { Credential.create_access(:seller) }

  def api_sign_in(user, credential)
    post(
      "/sign_in",
      headers: {
        "Accept" => "application/json",
        "X-API-KEY" => credential.key
      },
      params: {
        signin: {
          email: user.email,
          password: user.password
        }
      }
    )
    JSON.parse(response.body)
  end

  # Na primeira execução do let a função é chamada e seu retorno armazenado no let. A partir disso as próximas invocações já retornam direto para o resultado da primeira execução, sem precisar resolver a função em todas as invocações.
  let(:signed_in) { api_sign_in(user, credential) }

  describe "GET /show" do
    it "renders a successful response with stores data" do
      store = Store.create! name: "New Store", user: user
      get(
        "/stores/#{store.id}",
        headers: {
          "Accept" => "application/json",
          "Authorization" => "Bearer #{signed_in["token"]}"
        }
        )
      json = JSON.parse(response.body)

      expect(json["name"]).to eq store.name

    end
  end
end
