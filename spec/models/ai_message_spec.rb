# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiMessage, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:prompt) }
    it { is_expected.to validate_presence_of(:answer) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:ai_chat) }
  end
end
