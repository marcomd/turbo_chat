require 'rails_helper'

describe CreateAiImageJob, type: :job do
  let(:user) { create(:user) }
  let(:ai_chat) { create(:ai_chat, user:) }
  let(:prompt) { 'A beautiful sunset over the mountains' }
  let(:parameters) { { prompt:, ai_chat_id: ai_chat.id } }
  let(:stubbed_ai_image_service) { double(success?: true, result: true, errors: []) }
  let(:action) { -> { described_class.perform_now(prompt, ai_chat.id) } }

  before do
    # Stub the call to the external service to create the generated image w/o actually calling it
    allow(CreateAiImageService).to receive(:call).with(prompt:, ai_chat_id: ai_chat.id).and_return(stubbed_ai_image_service)
  end

  it 'calls the CreateAiImageService with the correct parameters' do
    expect(CreateAiImageService).to receive(:call).with(prompt:, ai_chat_id: ai_chat.id)

    action.call
  end
end
