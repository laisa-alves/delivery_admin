class ApplicationController < ActionController::Base
  # Métodos definidos aqui podem ser usados em qualquer controller
  def authenticate!
    if request.format == Mime[:json]
      check_token!
    else
      authenticate_user!
      check_user_discarded if user_signed_in?
    end
  end

  # Sobrescreve o método current_user herdado do devise
  def current_user
    if request.format == Mime[:json]
      @user
    else
      super
    end
  end

  # Recupera a credencial da aplicação que está usando a api
  def current_credential
    return nil if request.format != Mime[:json]
    Credential.find_by(key: request.headers["X-API-KEY"]) || Credential.new
  end

  private

  def is_buyer?
    (current_user && current_user.buyer?) && current_credential.buyer?
  end

  # Método para filtrar apenas buyers
  def only_buyers!
    is_buyer = (current_user && current_user.buyer?) && current_credential.buyer?

    if !is_buyer
      render json: {message: "Not authorized"}, status: 401
    end
  end

  # Verifica a existência e validade do token
  def check_token!
    if user = authenticate_with_http_token { |t, _| User.from_token(t) }
      @user = User.new(id: user[:id], role: user[:role], email: user[:email])
    else
      render json: {message: "Not authorized"}, status: 401
    end
  end

  def check_user_discarded
    if user_signed_in? && current_user.discarded?
      sign_out current_user
      flash[:alert] = "Sua conta foi desativada. Entre em contato com o suporte para obter mais informações."
      redirect_to root_path
    end
  end


end
