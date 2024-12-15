# frozen_string_literal: true

# It creates a new AiMessage related to the given AiChat.
# In addition, it creates AiChat if it doesn't exist.
#
# e.g.
# To create a new chat:
# - CreateAiChatMessageService.call(prompt: 'Hi!', user_id: 1)
# To create a new message in an existing chat:
# - CreateAiChatMessageService.call(prompt: 'Define the term "AI"', ai_chat_id: 1)
# result:
# #<AiMessage:0x00000001272c6870
#   id: 1,
#   ai_chat_id: 1,
#   prompt: "Hello!",
#   answer: "How can I assist you today?",
#   created_at: "2024-12-06 18:34:36.198933000 +0000",
#   updated_at: "2024-12-06 18:34:36.198933000 +0000">
class CreateAiChatMessageService
  prepend SimpleCommand

  DEFAULT_MODEL_NAME = "llama3.2"

  def initialize(prompt:, ai_chat_id: nil, user_id: nil)
    @ai_chat_id = ai_chat_id
    @prompt = prompt
    @user_id = user_id
  end

  # It creates and returns a new AiMessage related to the given/created AiChat
  # @param prompt [String] the user's message to the AI
  # @param ai_chat_id [Integer] [OPTIONAL] the AI chat id, if not provided it will create a new AiChat
  # @param user_id [Integer] [OPTIONAL] the user id to create a new AiChat, if the AiChat is not provided
  # @return [AiMessage] the created AiMessage
  def call
    if !ai_chat_id && !user_id
      errors.add(:ai_chat_id, "or user_id is required")
    elsif ai_chat_id && !ai_chat
      errors.add(:ai_chat, "not found")
    elsif !ai_chat_id && !ai_chat
      errors.add(:ai_chat, "not created, check attributes")
    elsif ai_chat.errors.any?
      errors.add(:ai_chat, ai_chat.errors.full_messages.to_sentence)
    end

    errors.add(:prompt, "is required") if prompt.blank?

    if errors.any?
      # notify_error
      return
    end

    llm_response = llm.chat(messages:)

    ai_message = ai_chat.ai_messages.create(prompt:, answer: llm_response.chat_completion)

    ai_message
  rescue StandardError
    # notify_error
  end

  private

  attr_reader :ai_chat_id, :prompt, :user_id

  # The LLM client.
  # @return [Langchain::LLM::Ollama] the LLM client
  def llm
    @llm ||= Langchain::LLM::Ollama.new(url: "http://localhost:11434", default_options: { chat_model: DEFAULT_MODEL_NAME })
  end

  # Find or create the AiChat on which add the AiMessage.
  def ai_chat
    @ai_chat ||=
      if ai_chat_id
        AiChat.find_by(id: ai_chat_id)
      else
        # Generally AI Chat is created in the controller to provide the user with the chat url and just wait the response.
        AiChat.create(user_id:, title: prompt.truncate(100), ai_model_name: DEFAULT_MODEL_NAME)
      end
  end

  # Builds the message history for the current chat
  # @return [Array] the message history
  # @example
  #     [
  #       { role: 'user', content: 'Hi! My name is Purple.' },
  #       { role: 'assistant',
  #         content: 'Hi, Purple!' },
  #       { role: 'user', content: "What's my name?" }
  #     ]
  def messages
    return [] unless ai_chat

    @messages ||=
      begin
        ai_chat.ai_messages.flat_map do |ai_message|
          [
            { role: "user", content: ai_message.prompt },
            { role: "assistant", content: ai_message.answer }
          ]
        end << { role: "user", content: prompt }
      end
  end
end
