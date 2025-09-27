class CreateDocumentChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :document_chunks do |t|
      t.text :content, null: false
      t.text :embedding, null: false # JSON array of floats
      t.string :source, null: false
      t.timestamps
    end

    add_index :document_chunks, :source
  end
end
