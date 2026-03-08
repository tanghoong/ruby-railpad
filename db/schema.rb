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

ActiveRecord::Schema[8.1].define(version: 2026_03_08_220234) do
  create_table "articles", force: :cascade do |t|
    t.string "author"
    t.text "content"
    t.datetime "created_at", null: false
    t.boolean "published", default: false, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_articles_on_created_at"
    t.index ["published"], name: "index_articles_on_published"
  end

  create_table "gists", force: :cascade do |t|
    t.integer "article_id"
    t.text "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "language", default: "ruby", null: false
    t.text "output"
    t.datetime "output_at"
    t.boolean "published", default: false, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id", "created_at"], name: "index_gists_on_article_id_and_created_at"
    t.index ["article_id"], name: "index_gists_on_article_id"
    t.index ["created_at"], name: "index_gists_on_created_at"
    t.index ["published"], name: "index_gists_on_published"
  end

  add_foreign_key "gists", "articles"
end
