# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "AiMessages", type: :request do
  let(:user) { create(:user) }
  let(:ai_chat) { create(:ai_chat, user:, title: "Title") }
  let(:ai_message) { create(:ai_message, ai_chat:) }

  # We use this to reuse the spec in other contexts, we are ready for the other actions
  shared_examples 'a not logged user' do
    it 'redirects to the login page' do
      action.call
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /create" do
    let(:action) { -> { post "/ai/#{ai_chat.id}/messages", params: params } }
    let(:params) { { prompt: "Hello" } }

    it_behaves_like 'a not logged user'

    context 'when user is logged in' do
      before do
        login_as user
      end

      context 'when the prompt is blank' do
        let(:params) { { prompt: "" } }

        it 'sets a flash alert' do
          action.call
          expect(flash[:alert]).to eq('Please set a prompt')
        end

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
end
