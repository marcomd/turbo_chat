# frozen_string_literal: true

class CreateAiChatMessageJob < ApplicationJob
  queue_as :default

  def perform(prompt, ai_chat_id)
    CreateAiChatMessageService.call(prompt:, ai_chat_id:)
  end
end
