# Rails Tutorial — Learn by Reading ror-cms

This tutorial walks you through every major Rails concept using the actual code
in this project. No prior Rails knowledge is assumed.

Work through the sections in order. Each one builds on the previous.

---

## Part 1 — How a Rails Request Works

Before touching any file, understand the journey of a single HTTP request.

When you visit `http://localhost:3000/articles`:

```text
Browser → Router → Controller → Model → Database
                                      ↓
Browser ← View   ← Controller ← Model ←
```

**Step by step:**

1. **Browser** sends `GET /articles` to the Rails server
2. **Router** (`config/routes.rb`) reads the URL and decides which controller
   action to call → `ArticlesController#index`
3. **Controller** (`app/controllers/articles_controller.rb`) runs the `index`
   method, asks the Model for data
4. **Model** (`app/models/article.rb`) queries the database and returns records
5. **Controller** passes the data to the **View**
6. **View** (`app/views/articles/index.html.erb`) builds HTML using the data
7. **HTML** is sent back to the browser

This MVC cycle happens for every page in every Rails application.

---

## Part 2 — The Router

Open [config/routes.rb](../config/routes.rb).

```ruby
Rails.application.routes.draw do
  resources :articles
  root "articles#index"
end
```

`resources :articles` is one line that generates **7 routes**. Run this to
see them all:

```bash
bundle exec rails routes
```

You will see:

```text
Prefix      Verb   URI Pattern                Controller#Action
articles    GET    /articles                  articles#index
new_article GET    /articles/new              articles#new
            POST   /articles                  articles#create
article     GET    /articles/:id              articles#show
edit_article GET   /articles/:id/edit         articles#edit
            PATCH  /articles/:id              articles#update
            DELETE /articles/:id              articles#destroy
```

**Key things to notice:**

- The **Prefix** column gives you helper method names. `articles_path` returns
  `/articles`. `article_path(@article)` returns `/articles/3`.
- The same URL (`/articles/:id`) handles GET (show), PATCH (update), and DELETE
  — the HTTP **verb** determines the action.
- `:id` is a dynamic segment captured as `params[:id]` in the controller.

**Try it:** In `app/views/articles/index.html.erb`, find
`link_to article.title, article`. Rails knows `article` is an Article record
and automatically generates the correct URL (`/articles/3`).

---

## Part 3 — The Model

Open [app/models/article.rb](../app/models/article.rb).

```ruby
class Article < ApplicationRecord
  validates :title,   presence: true, length: { minimum: 3, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :author,  presence: true, length: { minimum: 2, maximum: 100 }

  scope :published,   -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :recent,      -> { order(created_at: :desc) }

  def published_status
    published ? "Published" : "Draft"
  end
end
```

### 3.1 — ActiveRecord and SQL

`Article` inherits from `ApplicationRecord` → `ActiveRecord::Base`.
ActiveRecord **translates Ruby into SQL** automatically.

| Ruby | SQL |
| ---- | --- |
| `Article.all` | `SELECT * FROM articles` |
| `Article.find(3)` | `SELECT * FROM articles WHERE id = 3 LIMIT 1` |
| `Article.where(published: true)` | `SELECT * FROM articles WHERE published = 1` |
| `Article.order(created_at: :desc)` | `SELECT * FROM articles ORDER BY created_at DESC` |
| `article.save` | `INSERT INTO articles (...)` or `UPDATE articles SET ...` |
| `article.destroy` | `DELETE FROM articles WHERE id = ?` |

You never write SQL by hand. ActiveRecord handles it.

### 3.2 — Validations

Validations run automatically before `save` or `update`.
If any validation fails, the record is **not saved** and errors are
collected in `article.errors`.

```ruby
article = Article.new(title: "Hi")   # Title too short (< 3 chars)
article.save                          # → false
article.errors.full_messages          # → ["Title is too short (minimum is 3 characters)"]
```

**Try it in the console:**

```bash
bundle exec rails console
```

```ruby
a = Article.new(title: "OK", content: "Too short", author: "Me")
a.valid?         # → false
a.errors.full_messages
# => ["Content is too short (minimum is 10 characters)"]
```

### 3.3 — Scopes

Scopes are reusable, **chainable** query shortcuts.

```ruby
Article.published          # WHERE published = 1
Article.recent             # ORDER BY created_at DESC
Article.published.recent   # WHERE published = 1 ORDER BY created_at DESC
Article.recent.limit(5)    # ORDER BY ... LIMIT 5
```

They return an `ActiveRecord::Relation` — a lazy query that only hits the
database when you actually need the records (e.g., `.each`, `.to_a`, `.count`).

---

## Part 4 — The Controller

Open [app/controllers/articles_controller.rb](../app/controllers/articles_controller.rb).

### 4.1 — The index action

```ruby
def index
  @articles = Article.recent

  if params[:search].present?
    search_term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"
    @articles = @articles.where(
      "title LIKE ? OR content LIKE ? OR author LIKE ?",
      search_term, search_term, search_term
    )
  end

  if params[:status].present?
    case params[:status]
    when "published" then @articles = @articles.published
    when "draft"     then @articles = @articles.unpublished
    end
  end

  @articles = @articles.load
end
```

**What to notice:**

- Instance variables starting with `@` (like `@articles`) are automatically
  available in the view. Local variables are not.
- `params` is a hash of all values from the URL query string and form body.
  `params[:search]` reads the `?search=rails` part of the URL.
- `sanitize_sql_like` escapes `%` and `_` characters to prevent SQL injection
  in the LIKE query.
- `.load` executes the SQL immediately and caches the result, so calling
  `.size`, `.any?`, and `.each` in the view all reuse the same data
  (one query instead of four).

### 4.2 — before_action

```ruby
before_action :set_article, only: %i[show edit update destroy]

private

def set_article
  @article = Article.find(params.expect(:id))
end
```

`before_action` runs a method **before** the specified actions. This avoids
repeating `@article = Article.find(params[:id])` in every action.

If the article doesn't exist, `find` raises `ActiveRecord::RecordNotFound`
which Rails catches and returns a 404 response.

### 4.3 — Strong Parameters

```ruby
def article_params
  params.expect(article: [:title, :content, :author, :published])
end
```

This **whitelist** ensures that only the four listed fields can be assigned
from form data. Without this, a malicious user could send
`{ admin: true }` and change fields you didn't intend.

### 4.4 — respond_to and Flash

```ruby
def create
  @article = Article.new(article_params)

  respond_to do |format|
    if @article.save
      format.html { redirect_to @article, notice: "Article was successfully created." }
      format.json { render :show, status: :created, location: @article }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @article.errors, status: :unprocessable_entity }
    end
  end
end
```

- `respond_to` handles multiple formats from one action. A browser gets HTML;
  an API client gets JSON.
- `redirect_to @article, notice: "..."` — after a successful create, the user
  is redirected to the show page. The `notice:` is stored in the **flash**
  (a one-time message in the session) and displayed on the next page.
- `render :new, status: :unprocessable_entity` — on failure, re-render the
  form with the error messages visible. Status 422 tells the browser this was
  a validation error.

---

## Part 5 — Views and ERB

Open [app/views/articles/index.html.erb](../app/views/articles/index.html.erb).

### 5.1 — ERB syntax

```erb
<%# This is a comment — not rendered %>

<% @articles.each do |article| %>  ← Ruby, no output
  <%= article.title %>              ← Ruby, outputs the result
<% end %>
```

### 5.2 — The layout

[app/views/layouts/application.html.erb](../app/views/layouts/application.html.erb)
is the outer HTML shell. `<%= yield %>` is where the current page's content
is inserted.

```erb
<body>
  <header>...</header>
  <main>
    <%= yield %>   ← index.html.erb, show.html.erb, etc. appear here
  </main>
  <footer>...</footer>
</body>
```

### 5.3 — Partials

A **partial** is a reusable piece of a view. File names start with `_`.

```erb
<%# In new.html.erb %>
<%= render "form", article: @article %>

<%# In edit.html.erb %>
<%= render "form", article: @article %>
```

Both pages use `_form.html.erb` — the form code is written once
and shared. Inside the partial, `article` is a local variable
(not `@article`).

### 5.4 — URL helpers

Rails generates helper methods for every route:

```erb
<%= link_to "Articles", articles_path %>      ← /articles
<%= link_to "Edit", edit_article_path(@article) %>  ← /articles/3/edit
<%= link_to "View", article_path(@article) %>  ← /articles/3
<%# Shorthand — Rails infers the path from the object: %>
<%= link_to article.title, article %>         ← /articles/3
```

### 5.5 — Forms

```erb
<%= form_with(model: article) do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title, class: "form-control" %>

  <%= form.label :content %>
  <%= form.text_area :content, class: "form-control" %>

  <%= form.submit %>   ← "Create Article" or "Update Article" automatically
<% end %>
```

`form_with(model: article)` is smart:

- If `article` is a new record (not saved), it generates a POST to `/articles`
- If `article` is an existing record, it generates a PATCH to `/articles/:id`

You don't specify the URL or method manually.

---

## Part 6 — The Database

### 6.1 — Migrations

Open [db/migrate/](../db/migrate/). Every change to the database structure
is a migration — a Ruby file that describes the change.

```ruby
class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string  :title
      t.text    :content
      t.string  :author
      t.boolean :published, default: false, null: false
      t.timestamps           # creates created_at and updated_at
    end
    add_index :articles, :published
    add_index :articles, :created_at
  end
end
```

Run: `bundle exec rails db:migrate`

Rails tracks which migrations have run in the `schema_migrations` table.
Running `db:migrate` again is safe — it only runs pending migrations.

### 6.2 — Schema

[db/schema.rb](../db/schema.rb) is auto-generated. It always shows
the **current state** of the database:

```ruby
create_table "articles", force: :cascade do |t|
  t.string   "title"
  t.text     "content"
  t.string   "author"
  t.boolean  "published",   default: false, null: false
  t.datetime "created_at",  null: false
  t.datetime "updated_at",  null: false
  t.index ["created_at"],   name: "index_articles_on_created_at"
  t.index ["published"],    name: "index_articles_on_published"
end
```

### 6.3 — Rails Console

The console is the fastest way to experiment with your data and models.

```bash
bundle exec rails console
```

```ruby
# Create a record
Article.create!(
  title: "My Test Article",
  content: "Hello from the console, this is enough content.",
  author: "You",
  published: true
)

# Query records
Article.all
Article.count
Article.published.count
Article.recent.first

# Find and update
a = Article.find(1)
a.title                    # → "Welcome to our CMS"
a.update(published: false) # → true (saves immediately)

# Destroy
a.destroy

# Reload from the DB (if you modified in browser)
a.reload
```

Press `Ctrl+D` or type `exit` to leave the console.

---

## Part 7 — Testing

Open [test/models/article_test.rb](../test/models/article_test.rb).

### 7.1 — A basic test

```ruby
test "should not save article without title" do
  article = Article.new(content: "Some content here", author: "Test Author")
  assert_not article.save, "Saved the article without a title"
end
```

Every `test` block:

1. Sets up some state
2. Performs an action
3. Asserts the expected outcome

### 7.2 — Common assertions

| Assertion | Meaning |
| --------- | ------- |
| `assert condition` | condition is truthy |
| `assert_not condition` | condition is falsy |
| `assert_equal expected, actual` | two values match |
| `assert_response :success` | HTTP status is 200 |
| `assert_redirected_to url` | response is a redirect |
| `assert_select ".css-class"` | HTML contains element with class |
| `assert_difference "Model.count"` | count changes by 1 after a block |

### 7.3 — Fixtures

`test/fixtures/articles.yml` creates test data before every test:

```yaml
one:
  title: First Article Title
  content: This is the content for the first article...
  author: John Doe
  published: true
```

In the test: `@article = articles(:one)` → loaded from fixtures.

### 7.4 — Run tests

```bash
# All tests
bundle exec ruby -Itest test/models/article_test.rb
bundle exec ruby -Itest test/controllers/articles_controller_test.rb
```

---

## Part 8 — The JSON API

This app is also a REST API. Every HTML route has a JSON equivalent.

```bash
# List all articles
curl http://localhost:3000/articles.json

# Show one article
curl http://localhost:3000/articles/1.json

# Create an article
curl -X POST http://localhost:3000/articles.json \
  -H "Content-Type: application/json" \
  -d '{"article":{"title":"API Article","content":"Created via the API endpoint.","author":"Dev","published":true}}'

# Update an article
curl -X PATCH http://localhost:3000/articles/1.json \
  -H "Content-Type: application/json" \
  -d '{"article":{"published":false}}'

# Delete an article
curl -X DELETE http://localhost:3000/articles/1.json
```

The JSON response is built by [app/views/articles/_article.json.jbuilder](../app/views/articles/_article.json.jbuilder):

```ruby
json.extract! article, :id, :title, :content, :author, :published, :created_at, :updated_at
json.url article_url(article, format: :json)
```

`json.extract!` pulls attributes from the model directly into the JSON output.

---

## Part 9 — The Asset Pipeline

[app/assets/stylesheets/application.css](../app/assets/stylesheets/application.css)
contains all CSS for the project.

Rails uses **Propshaft** to serve assets. In development, files are served
directly. In production, they are fingerprinted (e.g.,
`application-abc123.css`) so browsers can be told to cache them forever.

The CSS in this project uses:

- **CSS custom properties** (variables): `var(--black)`, `var(--border)`
- **BEM naming**: `.article-row`, `.article-row__title`, `.badge--published`
- **Responsive breakpoints**: `@media (max-width: 479px)`, `@media (min-width: 768px)`

---

## Part 10 — Hotwire (Turbo + Stimulus)

This project includes **Turbo** and **Stimulus** via `turbo-rails` and
`stimulus-rails`.

**Turbo** makes page navigation feel like a SPA without writing JavaScript:

- Clicking links → Turbo intercepts, fetches the new page, swaps the `<body>`
- Form submissions → Turbo handles redirects and renders inline
- The `data: { turbo_confirm: "Are you sure?" }` on the delete button uses
  Turbo to show a native confirm dialog before sending the DELETE request

**Stimulus** is a lightweight JavaScript framework for adding behaviour to
HTML elements. This project does not yet have custom Stimulus controllers,
but the infrastructure is in place.

---

## Summary — What You've Learned

| Rails concept | Where it appears |
| ------------- | ---------------- |
| MVC pattern | `app/models/`, `app/views/`, `app/controllers/` |
| RESTful routing | `config/routes.rb`, `rails routes` |
| ActiveRecord ORM | `Article.all`, `.where`, `.find`, `.save` |
| Validations | `validates` in `article.rb` |
| Scopes | `scope :published` in `article.rb` |
| before_action | `set_article` in controller |
| Strong parameters | `article_params` method |
| respond_to | HTML + JSON from one action |
| Flash messages | `notice:` in redirects |
| ERB templates | `*.html.erb` files |
| Partials | `_form.html.erb`, `render "form"` |
| Layouts | `layouts/application.html.erb` |
| Migrations | `db/migrate/` |
| Seeds | `db/seeds.rb` |
| Fixtures | `test/fixtures/articles.yml` |
| Minitest | `test/models/`, `test/controllers/` |
| JSON API | `.json.jbuilder` files |
| Turbo | Delete confirmation, form handling |

**Next step:** Open [docs/NEW_MODULE_GUIDE.md](NEW_MODULE_GUIDE.md) to practice
building a new CRUD module from scratch, or [docs/LEARNING_ROADMAP.md](LEARNING_ROADMAP.md)
to see what features to add next.
