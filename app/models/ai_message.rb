# frozen_string_literal: true

class AiMessage < ApplicationRecord
  belongs_to :ai_chat
  has_one_attached :generated_image

  validates :prompt, presence: true

  scope :in_context, -> { where(excluded: false) }
end
