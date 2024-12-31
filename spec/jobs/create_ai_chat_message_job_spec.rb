# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(CreateAiChatMessageJob) do
  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:ai_chat) { create(:ai_chat, user:) }
  let(:ai_chat_id) { ai_chat.id }
  let(:prompt) { 'Hello' }

  it 'calls the CreateAiChatMessageService with correct params' do
    expect(CreateAiChatMessageService).to receive(:call).with(
      prompt:,
      ai_chat_id:
    )

    described_class.perform_now(
      prompt,
      ai_chat_id
    )
  end

  it 'queues the job' do
    expect(described_class.new.queue_name).to eq('default')
  end
end
