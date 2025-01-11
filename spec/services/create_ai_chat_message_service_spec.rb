require 'rails_helper'

describe CreateAiChatMessageService, type: :service do
  let(:user) { create(:user) }
  let(:ai_chat) { create(:ai_chat, user:) }
  let(:prompt) { 'Hello!' }
  let(:service) { described_class.new(**parameters) }

  # ---- Stubbing the external service ----
  let(:llm) { double(chat: llm_response) }
  let(:llm_response) { double(chat_completion: stubbed_answer) }
  let(:stubbed_answer) { 'This is a stubbed answer' }
  # ---------------------------------------

  before do
    # Stub the call to the external service to create the llm instance w/o actually calling it
    allow(service).to receive(:llm).and_return(llm)
  end

  shared_examples 'a service that fails' do
    it 'does NOT create a new AiMessage' do
      expect { service.call }.to_not change { AiMessage.count }
    end

    it 'does NOT success' do
      service.call
      expect(service.success?).to be_falsey
      expect(service.errors.any?).to be_truthy
    end
  end

  context 'when all parameters are present' do
    # Although is not necessary to provide both ai_chat_id and user_id, this is a tolerated case, user_id will be ignored
    let(:parameters) { { prompt:, ai_chat_id: ai_chat.id, user_id: user.id } }

    it 'creates a new AiMessage' do
      expect { service.call }.to change { AiMessage.count }.by(1)
      expect(AiMessage.last.answer).to eq(stubbed_answer)
    end

    it 'does NOT create a new AiChat' do
      expect { service.call }.to_not change { AiChat.count }
    end
  end

  context 'when ai_chat_id is provided' do
    let(:parameters) { { prompt:, ai_chat_id: ai_chat.id } }

    it 'creates a new AiMessage' do
      expect { service.call }.to change { AiMessage.count }.by(1)
    end

    it 'does NOT create a new AiChat' do
      expect { service.call }.to_not change { AiChat.count }
    end

    it 'calls action cable broadcasting' do
      expect(service).to receive(:show_spinner).with(message: prompt).ordered
      expect(service).to receive(:remove_spinner).ordered
      expect(service).to receive(:add_ai_message).with(ai_message: an_instance_of(AiMessage)).ordered
      service.call
    end
  end

  context 'when ai_chat_id is NOT provided' do
    let(:parameters) { { prompt:, user_id: user.id } }

    it 'creates a new AiChat and AiMessage' do
      expect { service.call }.to change { AiChat.count }.by(1).and change { AiMessage.count }.by(1)
    end
  end

  context 'when ai_chat_id and user_id are NOT provided' do
    let(:parameters) { { prompt: prompt } }

    it_behaves_like 'a service that fails'

    it 'add specific error message' do
      service.call
      expect(service.errors[:ai_chat_id]).to include('or user_id is required')
    end
  end

  context 'when prompt is blank' do
    let(:parameters) { { prompt: '', ai_chat_id: ai_chat.id } }

    it_behaves_like 'a service that fails'

    it 'add specific error message' do
      service.call
      expect(service.errors[:prompt]).to include('is required')
    end
  end

  context 'when ai_chat_id is provided but not found' do
    let(:parameters) { { prompt:, ai_chat_id: -1 } }

    it_behaves_like 'a service that fails'

    it 'adds an error for ai_chat not found' do
      service.call
      expect(service.errors[:ai_chat]).to include('not found')
    end
  end

  describe '#show_spinner' do
    let(:parameters) { { prompt:, ai_chat_id: ai_chat.id } }

    it 'broadcasts the spinner to the client' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_after_to).with([ ai_chat, 'ai_messages' ],
                                                                        target: "ai_chat_#{ai_chat.id}_messages",
                                                                        partial: 'ai_chats/spinner',
                                                                        locals: { message: prompt })
      service.send(:show_spinner, message: prompt)
    end
  end

  describe '#remove_spinner' do
    let(:parameters) { { prompt:, ai_chat_id: ai_chat.id } }

    it 'removes the spinner from the client' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_remove_to).with([ ai_chat, 'ai_messages' ], target: 'ai_chat__spinner')
      service.send(:remove_spinner)
    end
  end

  describe '#add_ai_message' do
    let(:ai_message) { create(:ai_message, ai_chat:) }
    let(:parameters) { { prompt:, ai_chat_id: ai_chat.id } }

    it 'broadcasts the new AI message to the client' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_append_to).with([ ai_chat, 'ai_messages' ],
                                                                         target: "ai_chat_#{ai_chat.id}_messages",
                                                                         partial: 'ai_messages/ai_message',
                                                                         locals: { ai_chat: ai_chat, ai_message:, is_new: true })
      service.send(:add_ai_message, ai_message: ai_message)
    end
  end
end
