class CreateGists < ActiveRecord::Migration[8.1]
  def change
    create_table :gists do |t|
      t.string   :title,       null: false
      t.text     :description
      t.text     :code,        null: false
      t.string   :language,    null: false, default: "ruby"
      t.text     :output
      t.datetime :output_at
      t.boolean  :published,   null: false, default: false
      t.references :article,   null: true, foreign_key: true

      t.timestamps
    end

    add_index :gists, :published
    add_index :gists, :created_at
    add_index :gists, [ :article_id, :created_at ]
  end
end
