class Api::V1::ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  respond_to :json

  rescue_from CanCan::AccessDenied do |exception|
    respond_with "Acesso negado. Você não está autorizado a acessar essa página", status: :unauthorized
  end

  # authentication for api
  helper_method :authenticate_user_by_token!
  def authenticate_user_by_token!
    if params[:token].present?
      user = User.find_by(token: params[:token])
      if user.nil? || ((params[:permission] == 'master') & !user.master?)
        raise CanCan::AccessDenied
      end
      sign_in user
    else
      raise CanCan::AccessDenied
    end
  end

  helper_method :authorize!
  def authorize!
    if current_user.master?
      # raise CanCan::AccessDenied.new('acesso negado por falta de credenciais')
    end
  end
end
