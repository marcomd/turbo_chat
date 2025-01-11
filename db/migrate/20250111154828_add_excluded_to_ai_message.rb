class AddExcludedToAiMessage < ActiveRecord::Migration[8.0]
  def change
    add_column :ai_messages, :excluded, :boolean, default: false
  end
end
