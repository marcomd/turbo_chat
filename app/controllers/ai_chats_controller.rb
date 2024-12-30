class AiChatsController < PrivateController
  before_action :set_ai_chat, only: [ :show ]

  # GET /ai
  def index
    @ai_chats = current_user.ai_chats.order(created_at: :desc)
  end

  # GET /ai/:id
  def show; end

  # GET /ai/new
  def new
    @ai_chat = current_user.ai_chats.build
  end

  private

  # We add this getter to avoid using the @ai_chat instance variable directly
  # and make it easier to share code.
  attr_reader :ai_chat

  def set_ai_chat
    # We retrieve the chat and related messages in a single query...
    @ai_chat = current_user.ai_chats.includes(:ai_messages).find(params[:id])
  end
end
