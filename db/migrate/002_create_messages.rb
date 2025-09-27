class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.text :content, null: false
      t.string :message_type, null: false
      t.integer :user_id, null: true
      t.timestamps
    end

    add_index :messages, [ :user_id, :created_at ]
  end
end
