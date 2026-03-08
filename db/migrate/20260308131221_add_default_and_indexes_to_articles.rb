class AddDefaultAndIndexesToArticles < ActiveRecord::Migration[8.1]
  def change
    # Backfill any NULL published values before adding the NOT NULL constraint
    Article.where(published: nil).update_all(published: false)

    # Enforce a proper default at the DB level
    change_column_default :articles, :published, from: nil, to: false
    change_column_null    :articles, :published, false

    # Indexes to speed up the status filter and the default sort
    add_index :articles, :published
    add_index :articles, :created_at
  end
end
