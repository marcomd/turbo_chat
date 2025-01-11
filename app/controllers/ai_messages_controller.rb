# frozen_string_literal: true

class AiMessagesController < PrivateController
  before_action :set_ai_chat
  before_action :set_ai_message, except: [ :create ]

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

  # PATCH /ai/:ai_chat_id/messages/:id/exclude
  def exclude
    @ai_message.update!(excluded: true)

    respond_to do |format|
      message = "Message hidden"
      format.html { redirect_to @ai_chat, notice: message }
      format.turbo_stream { flash.now[:notice] = message }
    end
  end

  # PATCH /ai/:ai_chat_id/messages/:id/restore
  def restore
    @ai_message.update!(excluded: false)

    respond_to do |format|
      message = "Message restored"
      format.html { redirect_to @ai_chat, notice: message }
      format.turbo_stream { flash.now[:notice] = message }
    end
  end

  # DELETE /ai/:ai_chat_id/messages/:id
  def destroy
    @ai_message.destroy!

    respond_to do |format|
      message = "Message deleted permanently!"
      format.html { redirect_to @ai_chat, notice: message }
      format.turbo_stream { flash.now[:notice] = message }
    end
  end

  private

  def set_ai_chat
    @ai_chat = current_user.ai_chats.find(params[:ai_chat_id])
  end

  def set_ai_message
    @ai_message = @ai_chat.ai_messages.find(params[:id])
  end

  def ai_message_params
    params.permit(:prompt, :ai_model_name)
  end
end
