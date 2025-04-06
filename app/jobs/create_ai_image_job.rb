# frozen_string_literal: true

class CreateAiImageJob < ApplicationJob
  queue_as :default

  def perform(prompt, ai_chat_id)
    CreateAiImageService.call(prompt:, ai_chat_id:)
  end
end
