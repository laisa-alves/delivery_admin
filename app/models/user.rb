class User < ApplicationRecord
  include Discard::Model

  class InvalidToken < StandardError; end

  enum :role, [:admin, :seller, :buyer]
  has_many :stores
  validates :role, presence: true

  # Cria o token para usuário válido
  def self.token_for(user)
    jwt_headers = {exp: 1.hour.from_now.to_i}
    payload = {id: user.id, email: user.email, role: user.role}
    JWT.encode payload.merge(jwt_headers), "muito.secreto", "HS256"
  end

  # Retorna dados do usuário a partir do token
  def self.from_token(token)
    decoded = JWT.decode(token, "muito.secreto", true, {algorithm: "HS256"})
    user_data = decoded[0].with_indifferent_access
    user_data
  rescue JWT::ExpiredSignature
    raise InvalidToken.new
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
