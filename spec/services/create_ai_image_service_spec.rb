require 'rails_helper'

describe CreateAiImageService, type: :service do
  let(:user) { create(:user) }
  let(:ai_chat) { create(:ai_chat, user:) }
  let(:prompt) { 'A serene mountain landscape at sunset' }
  let(:service) { described_class.new(**parameters) }
  let(:parameters) { { prompt:, ai_chat_id: ai_chat.id } }

  # ---- Stubbing the external service ----
  let(:image_generation_service) { double(success?: image_generation_service_success, status: image_generation_service_success ? '200' : '400') }
  let(:image_generation_service_success) { true }
  let(:stubbed_image) { Rails.root.join('spec', 'fixtures', 'images', 'landscape.jpg').read }
  # ---------------------------------------

  before do
    # Stub the ENV variable IMAGE_GENERATION_AUTH_TOKEN
    stub_const('ENV', ENV.to_h.merge('IMAGE_GENERATION_AUTH_TOKEN' => '123456'))

    # Stub the call to the external service to create the generated image w/o actually calling it
    allow(service).to receive(:image_generation_service).and_return(image_generation_service)
    allow(image_generation_service).to receive(:body).and_return(stubbed_image)
  end

  shared_examples 'a service that fails' do
    it 'does NOT create the ai_message generated_image' do
      expect { service.call }.to_not change(AiMessage, :count)
    end

    it 'does NOT success' do
      service.call
      expect(service.success?).to be_falsey
      expect(service.errors.any?).to be_truthy
    end
  end

  it 'creates ai_message with the generated image' do
    expect { service.call }.to change(AiMessage, :count).by(1)

    ai_message = ai_chat.ai_messages.last
    expect(ai_message).to be_present
    expect(ai_message.prompt).to eq(prompt)
    expect(ai_message.answer).to be_blank
    expect(ai_message.generated_image.attached?).to eq(true)
  end

  it 'successes' do
    service.call
    expect(service.success?).to eq(true)
    expect(service.errors.any?).to be_falsey
  end

  context 'when prompt is blank' do
    let(:prompt) { '' }

    it_behaves_like 'a service that fails'

    it 'adds a blank error' do
      service.call
      expect(service.errors[:prompt]).to include("is required")
    end
  end

  context 'when ai_chat_id is NOT provided' do
    let(:parameters) { { prompt: } }

    it_behaves_like 'a service that fails'

    it 'adds a blank error' do
      service.call
      expect(service.errors[:ai_chat_id]).to include("is required")
    end
  end

  context 'when ai_chat_id is provided but not found' do
    let(:parameters) { { prompt:, ai_chat_id: -1 } }

    it_behaves_like 'a service that fails'

    it 'adds a not found error' do
      service.call
      expect(service.errors[:ai_chat]).to include('not found')
    end
  end

  describe '#show_spinner' do
    it 'broadcasts the spinner to the client' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_after_to).with([ ai_chat, 'ai_messages' ],
                                                                         target: "ai_chat_#{ai_chat.id}_messages",
                                                                         partial: 'ai_chats/spinner',
                                                                         locals: { message: prompt })
      service.send(:show_spinner, message: prompt)
    end
  end

  describe '#remove_spinner' do
    it 'removes the spinner from the client' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_remove_to).with([ ai_chat, 'ai_messages' ], target: 'ai_chat__spinner')
      service.send(:remove_spinner)
    end
  end

  context 'when the image service raise an error' do
    let(:error_message) { 'Prompt Image generation failed: 400' }
    let(:image_generation_service_success) { false }

    it_behaves_like 'a service that fails'

    it 'notify the error' do
      expect(service).to receive(:notify_error).with(message: error_message)
      service.call
    end
  end
end
