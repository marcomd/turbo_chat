class CreateAiMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_messages do |t|
      t.references :ai_chat, null: false, foreign_key: true
      t.text :prompt
      t.text :answer

      t.timestamps
    end
  end
end
