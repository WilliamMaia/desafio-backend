class Api::V1::MessagesController < Api::V1::ApplicationController
  before_action :authenticate_user!

  # GET /messages
  def index
    @messages = current_user.master? ? Message.master_messages.ordered : Message.sent_to(current_user).ordered
    respond_with @messages
  end

  # POST /messages
  def create
    user = User.find_by_email(message_params[:receiver_email]) #find user by email instead of id
    @message = Message.new(message_params.merge(from: current_user.id)) # adds current_user id as sender of the message
    @message.to = user.id if user # if user is not found , message is rejected

    if @message.save
      head :ok
    else
      head :bad_request
    end
  end

  # GET /messages/sent
  def sent
    @messages = Message.sent_from(current_user).ordered
    respond_with @messages
  end

  # PATCH /messages/:id/archive
  def archive
    @message = Message.find_by_title(params[:title])
    @message.archived!

    head :ok
  end

  # GET /messages/archived
  def archived
    @messages = Message.includes(:sender).archived.ordered
    respond_with @messages
  end

  # GET /messages/archive_multiple
  def archive_multiple
    messages = Message.find(params[:message_ids])
    messages.each do |message|
      message.archived!
    end
  end
end
