# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "AiChats", type: :request do
  let(:user) { create(:user) }

  describe "GET /index" do
    let(:action) { -> { get "/ai" } }

    it_behaves_like 'a not logged user'

    context 'when user is logged in' do
      before do
        login_as user
      end

      it 'returns http success' do
        action.call
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        action.call
        expect(response).to render_template(:index)
      end

      context 'when there are NO chats' do
        it 'assigns an empty array to @ai_chats' do
          action.call
          expect(assigns(:ai_chats)).to eq([])
        end
      end

      context 'when there are chats' do
        let!(:ai_chat) { create(:ai_chat, user:) }

        it 'assigns an array to @ai_chats' do
          action.call
          expect(assigns(:ai_chats)).to eq([ ai_chat ])
        end
      end
    end
  end

  describe "GET /show" do
    let(:action) { -> { get "/ai/#{ai_chat.id}" } }
    let(:ai_chat) { create(:ai_chat, user:) }

    it_behaves_like 'a not logged user'

    context 'when user is logged in' do
      before do
        login_as user
      end

      context 'when the chat does not exist' do
        let(:ai_chat) { double(id: 123) }

        it 'return a not found' do
          action.call
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the chat exists' do
        it 'returns http success' do
          action.call
          expect(response).to have_http_status(:success)
        end

        it 'renders the show template' do
          action.call
          expect(response).to render_template(:show)
        end

        it 'assigns the chat to @ai_chat' do
          action.call
          expect(assigns(:ai_chat)).to eq(ai_chat)
        end
      end
    end
  end

  describe "GET /new" do
    let(:action) { -> { get "/ai/new" } }

    it_behaves_like 'a not logged user'

    context 'when user is logged in' do
      before do
        login_as user
      end

      it 'returns http success' do
        action.call
        expect(response).to have_http_status(:success)
      end

      it 'renders the new template' do
        action.call
        expect(response).to render_template(:new)
      end

      it 'assigns a new AiChat to @ai_chat' do
        action.call
        expect(assigns(:ai_chat)).to be_a_new(AiChat)
      end
    end
  end

  describe "POST /create" do
    let(:action) { -> { post "/ai", params: } }
    let(:params) { { prompt: "Hello", ai_model_name: "llama3.2" } }

    it_behaves_like 'a not logged user'

    context 'when user is logged in' do
      before do
        login_as user
      end

      it 'creates a new chat' do
        expect { action.call }.to change { AiChat.count }.by(1)
      end

      it 'redirects to the chat page' do
        action.call
        expect(response).to redirect_to(ai_chat_path(AiChat.last))
      end

      it 'shows a flash message' do
        action.call
        expect(flash[:notice]).to eq("Chat created, please wait for a response.")
      end

      it 'enqueues a job' do
        expect { action.call }.to have_enqueued_job(CreateAiChatMessageJob)
      end

      context 'when the chat is not created' do
        before do
          allow(AiChat).to receive(:build).and_return(AiChat.new)
        end

        it 'does not create a new chat' do
          expect { action.call }.not_to change { AiChat.count }
        end

        it 'renders the new template' do
          action.call
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe "POST /ask" do
    let(:action) { -> { post "/ai/#{ai_chat.id}/ask", params: } }
    let(:ai_chat) { create(:ai_chat, user:, title: "Title") }
    let(:params) { { prompt: "Hello" } }

    it_behaves_like 'a not logged user'

    context 'when user is logged in' do
      before do
        login_as user
      end

      context 'when the prompt is blank' do
        let(:params) { { prompt: "" } }

        it 'does NOT enqueues a job' do
          expect { action.call }.to_not have_enqueued_job(CreateAiChatMessageJob)
        end
      end

      context 'when the prompt is not blank' do
        it 'enqueues a job' do
          expect { action.call }.to have_enqueued_job(CreateAiChatMessageJob)
        end
      end
    end
  end

  describe "DELETE /destroy" do
    let(:action) { -> { delete "/ai/#{ai_chat.id}" } }
    let!(:ai_chat) { create(:ai_chat, user:) }

    it_behaves_like 'a not logged user'

    context 'when user is logged in' do
      before do
        login_as user
      end

      it 'destroys the chat' do
        expect { action.call }.to change { AiChat.count }.by(-1)
      end

      it 'shows a flash message' do
        action.call
        expect(flash[:notice]).to eq("AI chat `#{ai_chat.title}` was successfully destroyed.")
      end
    end
  end
end
