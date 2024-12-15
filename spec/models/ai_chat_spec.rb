# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiChat, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:ai_model_name) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:ai_messages).dependent(:delete_all) }
  end

  describe 'constants' do
    it 'has a SUPPORTED_AI_MODELS constant' do
      expect(described_class::SUPPORTED_AI_MODELS).to be_a(Array)
      expect(described_class::SUPPORTED_AI_MODELS).to include('llama3.2')
    end
  end
end
