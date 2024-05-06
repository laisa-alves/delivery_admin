class ApplicationController < ActionController::Base
  # Métodos definidos aqui podem ser usados em qualquer controller
  def authenticate!
    if request.format == Mime[:json]
      check_token!
    else
      authenticate_user!
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
      @user = user
    else
      render json: {message: "Not authorized"}, status: 401
    end
  end
end
