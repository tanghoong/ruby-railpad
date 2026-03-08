json.extract! gist, :id, :title, :description, :code, :language, :output, :output_at,
                     :published, :article_id, :created_at, :updated_at
json.url gist_url(gist, format: :json)
