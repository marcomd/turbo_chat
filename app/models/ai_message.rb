# frozen_string_literal: true

class AiMessage < ApplicationRecord
  belongs_to :ai_chat

  validates :prompt, presence: true
  validates :answer, presence: true
end
