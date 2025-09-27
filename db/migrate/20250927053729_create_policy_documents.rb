class CreatePolicyDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :policy_documents do |t|
      t.string :title
      t.text :content
      t.json :metadata
      t.string :source_file
      t.string :sheet_name

      t.timestamps
    end
  end
end
