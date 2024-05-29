
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_user, only: [:destroy]

  # GET /users
  def index
    @users = User.kept.all
  end

  # GET /users/new
  def admin_new
    @user = User.new
  end

  # POST /users
  def admin_create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'Usuário criado com sucesso.'
    else
      render :admin_new, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.discard
    respond_to do |format|
      format.html { redirect_to users_path, notice: 'Usuário excluído com sucesso.' }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def authenticate_admin!
    redirect_to root_path, alert: 'Acesso negado.' unless current_user.admin?
  end
end
