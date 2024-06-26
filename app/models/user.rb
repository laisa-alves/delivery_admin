class User < ApplicationRecord
  include Discard::Model

  class InvalidToken < StandardError; end

  enum :role, [:admin, :seller, :buyer]
  has_many :stores, dependent: :destroy
  validates :role, presence: true

  after_discard :discard_associated_stores

  # Cria o token para usuário válido
  def self.token_for(user)
    jwt_headers = {exp: 1.hour.from_now.to_i}
    payload = {id: user.id, email: user.email, role: user.role}
    JWT.encode payload.merge(jwt_headers), Rails.application.credentials.jwt[:decode], "HS256"
  end

  # Retorna dados do usuário a partir do token
  def self.from_token(token)
    secret_key = Rails.application.credentials.jwt[:decode]
    decoded = JWT.decode(token, secret_key, true, {algorithm: "HS256"})
    user_data = decoded[0].with_indifferent_access
    user_data
  rescue JWT::ExpiredSignature
    raise InvalidToken.new
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  private

  def discard_associated_stores
    stores.discard_all
  end
end
