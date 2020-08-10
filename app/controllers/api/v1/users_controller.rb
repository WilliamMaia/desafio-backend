class Api::V1::UsersController < Api::V1::ApplicationController
  before_action :authenticate_user_by_token!
  skip_before_action :verify_authenticity_token
  # before_action :authorize!

  # GET /users
  def index
    @users = current_user.master? ? User.all : User.normal
    respond_with @users
  end

  # PATCH /users/:id
  def update
    begin
      if user_params[:password].blank? || user_params[:password_confirmation].blank? # remove password if both fields are not filled
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      user = User.find(params[:id])
      user_has_permission = (current_user.id == user.id || current_user.master?)

      if user_has_permission && user.update(user_params)
        head :ok
      else
        respond_with "erro", status: :bad_request
      end
    rescue StandardError => e
      respond_with e.message, status: :bad_request
    end
  end

  # GET /users/:id/messages
  def messages
    user_id = current_user.id
    @messages = Message.where(to: user_id)
                       .or(Message.where(from: user_id))
                       .ordered
                       .includes(:sender,:receiver)

    respond_with @messages.as_json(include: [:sender,:receiver])
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
