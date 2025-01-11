class AiChatsController < PrivateController
  before_action :set_ai_chat, only: [ :show, :destroy ]

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

  # POST /ai/create
  def create
    @ai_chat = AiChat.build(user_id: current_user.id,
                            ai_model_name: ai_message_params[:ai_model_name].presence || CreateAiChatMessageService::DEFAULT_MODEL_NAME,
                            title: ai_message_params[:prompt].truncate(100))

    respond_to do |format|
      if @ai_chat.save
        # We delay the start to allow the controller to finish before starting the job
        CreateAiChatMessageJob.set(wait: 0.5.seconds).perform_later(ai_message_params[:prompt], @ai_chat.id)

        message = "Chat created, please wait for a response."

        format.html { redirect_to(ai_chat_url(@ai_chat), notice: message) }
        format.json { render(:show, status: :created, location: @ai_chat) }
      else
        format.html { render(:new, status: :unprocessable_entity) }
        format.json { render(json: @ai_chat.errors, status: :unprocessable_entity) }
      end
    end
  end

  # DELETE /ai_chats/:id
  def destroy
    @ai_chat.destroy!

    message = "AI chat `#{@ai_chat.title}` was successfully destroyed."

    respond_to do |format|
      format.html { redirect_to(ai_chat_url, notice: message) }
      format.turbo_stream { flash.now[:notice] = message }
      format.json { head(:no_content) }
    end
  end

  private

  # We add this getter to avoid using the @ai_chat instance variable directly
  # and make it easier to share code.
  attr_reader :ai_chat

  def set_ai_chat
    # We retrieve the chat and related messages in a single query...
    @ai_chat = current_user.ai_chats.includes(:ai_messages).find(params[:id])
  end

  def ai_message_params
    params.permit(:prompt, :ai_model_name)
  end
end
