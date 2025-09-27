# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_27_053734) do
  create_table "document_embeddings", force: :cascade do |t|
    t.integer "policy_document_id", null: false
    t.string "content_hash"
    t.text "embedding"
    t.text "chunk_text"
    t.integer "chunk_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_document_id"], name: "index_document_embeddings_on_policy_document_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.string "message_type", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "created_at"], name: "index_messages_on_user_id_and_created_at"
  end

  create_table "policy_documents", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.json "metadata"
    t.string "source_file"
    t.string "sheet_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "document_embeddings", "policy_documents"
end
