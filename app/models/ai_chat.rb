  # frozen_string_literal: true

  class AiChat < ApplicationRecord
    belongs_to :user

    has_many :ai_messages, -> { order(id: :asc) }, dependent: :delete_all

    SUPPORTED_AI_MODELS = %w[llama3.2 llama3.1 llama3 mistral openhermes2.5-mistral qwen2.5-coder gemma2].freeze

    validates :ai_model_name, presence: true, inclusion: { in: SUPPORTED_AI_MODELS }
  end
