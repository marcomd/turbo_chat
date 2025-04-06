class AddChatTypeToAiChat < ActiveRecord::Migration[8.0]
  def change
    add_column :ai_chats, :chat_type, :integer, limit: 1, default: 0
  end
end
