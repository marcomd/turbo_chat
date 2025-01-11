# frozen_string_literal: true

class AiMessagesController < PrivateController
  before_action :set_ai_chat

  # POST /ai/:ai_chat_id/ai_messages
  def create
    respond_to do |format|
      if ai_message_params[:prompt].present?
        # Add a delay to avoid to show the spinner before the view is rendered
        CreateAiChatMessageJob.set(wait: 0.5.seconds).perform_later(ai_message_params[:prompt], @ai_chat.id)

        format.html { redirect_to(ai_chat_path(@ai_chat)) }
        format.json { render(:show, status: :created, location: @ai_chat) }
        format.turbo_stream { }
      else
        message = "Please set a prompt"

        format.html { redirect_to(ai_chat_path(@ai_chat), alert: message) }
        format.json { render(json: { message: }, status: :unprocessable_entity) }
        format.turbo_stream { flash.now[:alert] = message }
      end
    end
  end

  private

  def set_ai_chat
    @ai_chat = current_user.ai_chats.find(params[:ai_chat_id])
  end

  def ai_message_params
    params.permit(:prompt, :ai_model_name)
  end
end
