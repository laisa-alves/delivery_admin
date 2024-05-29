
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:index, :destroy]
  before_action :set_user, only: [:destroy]

  # GET /users
  def index
    @users = User.kept.all
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

  def set_user
    @user = User.find(params[:id])
  end

  def authenticate_admin!
    redirect_to root_path, alert: 'Acesso negado.' unless current_user.admin?
  end
end
