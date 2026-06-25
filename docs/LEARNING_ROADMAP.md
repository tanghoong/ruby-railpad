# Learning Roadmap — Features to Add

Each feature below is a real production Rails pattern. They are ordered from easiest to hardest. Implementing them in this project is the fastest way to learn Rails the right way.

---

## Level 1 — Foundations (start here)

### 1. Pagination with Pagy
**What it teaches:** Query optimization, gem integration, view helpers, URL params.

```ruby
# Gemfile
gem "pagy"

# Controller
include Pagy::Backend
@pagy, @articles = pagy(@articles, limit: 10)

# View
include Pagy::Frontend
<%== pagy_nav(@pagy) %>
```

**Why it matters:** Without pagination, loading 10,000 articles crashes your app. Every production Rails app paginates.

---

### 2. Slug-based URLs
**What it teaches:** Model callbacks (`before_save`), custom routing, `friendly_id` gem.

Instead of `/articles/3`, show `/articles/getting-started-with-rails`.

```ruby
# Gemfile
gem "friendly_id"

# Migration
add_column :articles, :slug, :string, null: false, default: ""
add_index  :articles, :slug, unique: true

# Model
extend FriendlyId
friendly_id :title, use: :slugged
```

**Why it matters:** All production apps use human-readable URLs for SEO and user experience.

---

### 3. Flash message types
**What it teaches:** Rails conventions, view helpers, partial rendering.

Expand the current basic flash to support `notice`, `alert`, `error`, `info` with different visual treatments.

```ruby
# In controller
redirect_to articles_path, notice: "Saved!", status: :see_other
redirect_to articles_path, alert: "Something went wrong"
```

**Why it matters:** The pattern of `redirect_to + flash` is used everywhere in Rails.

---

## Level 2 — Data Modelling

### 4. Categories (has_many / belongs_to)
**What it teaches:** Associations, migrations, foreign keys, form `collection_select`.

```ruby
# New model
rails generate model Category name:string:uniq

# Migration
add_reference :articles, :category, foreign_key: true

# Models
class Article < ApplicationRecord
  belongs_to :category, optional: true
end

class Category < ApplicationRecord
  has_many :articles
end
```

Filter articles by category on the index page.

---

### 5. Tags (has_many :through)
**What it teaches:** Many-to-many associations, join tables, `has_many :through`.

```ruby
rails generate model Tag name:string
rails generate model ArticleTag article:references tag:references

class Article < ApplicationRecord
  has_many :article_tags
  has_many :tags, through: :article_tags
end
```

**Why it matters:** The most common data relationship in real applications.

---

### 6. Author as a User model
**What it teaches:** `has_secure_password`, sessions, authentication from scratch.

Instead of a free-text author field, make Article `belong_to :user`.

```ruby
rails generate model User name:string email:string:uniq password_digest:string

class User < ApplicationRecord
  has_secure_password  # requires bcrypt gem
  has_many :articles
end
```

Add login/logout with `SessionsController` and store `current_user` in the session.

---

## Level 3 — User Experience

### 7. Authentication with Devise
**What it teaches:** Gem-based auth, Devise helpers (`current_user`, `authenticate_user!`), route protection.

```ruby
# Gemfile
gem "devise"

# Setup
rails generate devise:install
rails generate devise User

# Controller protection
before_action :authenticate_user!, except: [:index, :show]
```

After adding auth, articles should belong to the logged-in user, and only authors can edit/delete their own articles.

---

### 8. Rich Text Editor (Action Text)
**What it teaches:** Action Text, Active Storage, Trix editor, `has_rich_text`.

Replace the plain textarea with a full WYSIWYG editor — Rails ships with one built-in.

```ruby
# Enable Action Text
rails action_text:install

# Model
class Article < ApplicationRecord
  has_rich_text :content
end

# View — one line replaces the textarea
<%= form.rich_text_area :content %>
```

---

### 9. Image Uploads (Active Storage)
**What it teaches:** Active Storage, cloud storage adapters (S3, GCS), file variants/resizing.

Add a cover image to each article.

```ruby
# Setup
rails active_storage:install
rails db:migrate

# Model
class Article < ApplicationRecord
  has_one_attached :cover_image
end

# View
<%= form.file_field :cover_image %>
<%= image_tag @article.cover_image if @article.cover_image.attached? %>
```

---

## Level 4 — Production Patterns

### 10. Soft Delete (Discard gem)
**What it teaches:** `default_scope`, model callbacks, data preservation, auditing.

Instead of deleting records permanently, mark them as discarded. They can be restored.

```ruby
# Gemfile
gem "discard"

# Migration
add_column :articles, :discarded_at, :datetime
add_index  :articles, :discarded_at

# Model
include Discard::Model
default_scope { kept }
```

**Why it matters:** In production, you almost never actually delete records. You hide them.

---

### 11. Background Jobs (Solid Queue is already installed)
**What it teaches:** Active Job, SolidQueue, async processing, job queues.

Send an email notification when a new article is published.

```ruby
# Generate mailer
rails generate mailer ArticleMailer published

# Generate job
rails generate job NotifySubscribers

class NotifySubscribersJob < ApplicationJob
  queue_as :default

  def perform(article)
    ArticleMailer.published(article).deliver_now
  end
end

# In controller — runs in background, doesn't slow the request
NotifySubscribersJob.perform_later(@article) if @article.published?
```

---

### 12. Caching (Fragment Caching)
**What it teaches:** `cache` helper, cache keys, cache invalidation, performance.

Cache the article list so repeated visits skip the database entirely.

```erb
<%# View — wraps the rendered HTML in the cache store %>
<% cache @articles do %>
  <% @articles.each do |article| %>
    ...
  <% end %>
<% end %>

<%# Single record with automatic expiry on update %>
<% cache article do %>
  <%= render article %>
<% end %>
```

Rails automatically invalidates the cache when the model's `updated_at` changes.

---

### 13. Scopes + Model Concerns
**What it teaches:** DRY code, `ActiveSupport::Concern`, reusable model behaviour.

Extract shared logic (e.g. publishable behaviour) into a concern:

```ruby
# app/models/concerns/publishable.rb
module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published,   -> { where(published: true) }
    scope :unpublished, -> { where(published: false) }
    scope :recent,      -> { order(created_at: :desc) }
  end

  def published_status
    published? ? "Published" : "Draft"
  end
end

# app/models/article.rb
class Article < ApplicationRecord
  include Publishable
end
```

**Why it matters:** Concerns are how Rails avoids duplicating logic across models.

---

### 14. API versioning
**What it teaches:** Namespace routing, respond_to, versioned JSON APIs, serializers.

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :articles, only: [:index, :show, :create, :update, :destroy]
  end
end

# app/controllers/api/v1/articles_controller.rb
class Api::V1::ArticlesController < ApplicationController
  def index
    render json: Article.recent.limit(20)
  end
end
```

---

### 15. Testing Best Practices
**What it teaches:** TDD workflow, factory patterns, test coverage, assertion depth.

Upgrade the existing tests:

```ruby
# Gemfile :test group
gem "factory_bot_rails"  # Better than fixtures for complex data
gem "faker"              # Realistic fake data

# test/factories/articles.rb
FactoryBot.define do
  factory :article do
    title   { Faker::Lorem.sentence(word_count: 5) }
    content { Faker::Lorem.paragraphs(number: 3).join("\n") }
    author  { Faker::Name.name }
    published { true }
  end

  trait :draft do
    published { false }
  end
end

# Usage in tests
article = create(:article)
draft   = create(:article, :draft)
```

---

## Suggested Implementation Order

| Priority | Feature | Key Concept |
|---|---|---|
| 1 | Pagination (Pagy) | Gems, query optimization |
| 2 | Categories | has_many / belongs_to |
| 3 | User model + sessions | has_secure_password, auth |
| 4 | Devise | Production auth gem |
| 5 | Slug URLs | friendly_id, callbacks |
| 6 | Tags | has_many :through |
| 7 | Action Text | Built-in rich text |
| 8 | Active Storage | File uploads |
| 9 | Background Jobs | Async work |
| 10 | Soft Delete | Data preservation |
| 11 | Caching | Performance |
| 12 | API versioning | Namespaced controllers |
| 13 | Concerns | Code organization |
| 14 | FactoryBot | Better testing |

---

*Each feature maps directly to a chapter in the official [Rails Guides](https://guides.rubyonrails.org/). Use this project as your sandbox — break things, fix them, understand why.*
