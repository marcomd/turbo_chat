class CreateAiChats < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_chats do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :ai_model_name

      t.timestamps
    end
  end
end
