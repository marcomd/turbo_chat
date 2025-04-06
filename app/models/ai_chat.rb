  # frozen_string_literal: true

  class AiChat < ApplicationRecord
    belongs_to :user

    has_many :ai_messages, -> { order(id: :asc) }, dependent: :delete_all

    SUPPORTED_AI_MODELS = {
      text: %w[deepseek-r1 llama3.2 llama3.1 llama3 mistral openhermes2.5-mistral qwen2.5-coder gemma2],
      image: %w[sdxl-turbo sdxl-anime]
    }.freeze

    validates :ai_model_name, presence: true, inclusion: { in: SUPPORTED_AI_MODELS[:text] + SUPPORTED_AI_MODELS[:image] }

    enum :chat_type, { text: 0, image: 1 }
  end
