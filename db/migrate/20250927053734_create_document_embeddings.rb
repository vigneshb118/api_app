class CreateDocumentEmbeddings < ActiveRecord::Migration[8.0]
  def change
    create_table :document_embeddings do |t|
      t.references :policy_document, null: false, foreign_key: true
      t.string :content_hash
      t.text :embedding
      t.text :chunk_text
      t.integer :chunk_index

      t.timestamps
    end
  end
end
