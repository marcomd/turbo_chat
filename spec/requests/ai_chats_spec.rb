# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "AiChats", type: :request do
  let(:user) { create(:user) }

  describe "GET /index" do
    let(:action) { -> { get "/ai" } }

    context 'when user is not logged in' do
      it 'redirects to the login page' do
        action.call
        expect(response).to redirect_to(new_user_session_path)
      end
    end

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
          expect(assigns(:ai_chats)).to eq([ai_chat])
        end
      end
    end
  end

  describe "GET /show" do
    let(:action) { -> { get "/ai/#{ai_chat.id}" } }
    let(:ai_chat) { create(:ai_chat, user:) }

    context 'when user is not logged in' do
      it 'redirects to the login page' do
        action.call
        expect(response).to redirect_to(new_user_session_path)
      end
    end

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

    context 'when user is not logged in' do
      it 'redirects to the login page' do
        action.call
        expect(response).to redirect_to(new_user_session_path)
      end
    end

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
end
