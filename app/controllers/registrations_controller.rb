class RegistrationsController < ApplicationController
  skip_forgery_protection only: [:create, :me, :sign_in]
  before_action :authenticate!, only: [:me]
  rescue_from User::InvalidToken, with: :not_authorized

  def sign_in
    user = User.find_by(email: sign_in_params[:email])

    if !user || !user.valid_password?(sign_in_params[:password])
      render json: {message: "Nope!"}, status: 401
    else
      token = User.token_for(user)
      render json: {email: user.email, token: token}
    end

  end

  def me
    render json: {id: current_user.id, email: current_user.email, role: current_user.role}
  end

  def create
    @user = User.new(user_params)
    if @user.save!
      render json: { "email": @user.email }
    end
  end

  private
  def not_authorized(e)
    render json: {message: "Nope!"}, status:401
  end

  def sign_in_params
    params.required(:signin).permit(:email, :password)
  end

  def user_params
    params.required(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
