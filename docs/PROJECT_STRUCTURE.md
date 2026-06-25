# Project Structure — ror-cms

A complete reference for every folder and file in this project.
Use this as a map when you are exploring the codebase.

---

## Top-level layout

```
ror-cms/
├── app/                  ← Your application code lives here
├── bin/                  ← Executable scripts (rails, bundle, etc.)
├── config/               ← Configuration files
├── db/                   ← Database schema and migrations
├── docs/                 ← Project documentation (this folder)
├── lib/                  ← Custom library code (empty for now)
├── log/                  ← Server log files
├── public/               ← Static files served directly by the web server
├── script/               ← Utility scripts (empty for now)
├── storage/              ← SQLite database files and Active Storage uploads
├── test/                 ← Automated test suite
├── tmp/                  ← Temporary files (cache, pids) — not committed
├── trash/                ← Removed files kept for reference
├── vendor/               ← Installed gems (bundle install writes here)
├── Gemfile               ← Lists all Ruby gem dependencies
├── Gemfile.lock          ← Exact locked versions of every gem
├── Rakefile              ← Defines rake tasks available to run
├── Dockerfile            ← Container definition for deployment
├── Procfile.dev          ← Process definitions for local dev with foreman
└── config.ru             ← Rack entry point (how the web server boots Rails)
```

---

## `app/` — Application Code

This is the heart of the project. Rails follows the **MVC** pattern
(Model → View → Controller). Everything in `app/` maps to one of those layers.

```
app/
├── assets/
│   └── stylesheets/
│       └── application.css      ← All CSS for the project
├── controllers/
│   ├── application_controller.rb
│   └── articles_controller.rb   ← Handles every HTTP request for articles
├── models/
│   ├── application_record.rb
│   └── article.rb               ← Article data model, validations, scopes
└── views/
    ├── articles/
    │   ├── _form.html.erb        ← Shared form (used by new + edit pages)
    │   ├── _article.html.erb     ← JSON partial (used by the API)
    │   ├── _article.json.jbuilder
    │   ├── index.html.erb        ← Article list page
    │   ├── index.json.jbuilder   ← JSON response for GET /articles.json
    │   ├── new.html.erb          ← "New Article" page
    │   ├── edit.html.erb         ← "Edit Article" page
    │   ├── show.html.erb         ← Single article detail page
    │   └── show.json.jbuilder    ← JSON response for GET /articles/:id.json
    └── layouts/
        └── application.html.erb ← Master HTML template (wraps every page)
```

### `app/models/article.rb`

The **Model** is the layer that talks to the database.

```ruby
class Article < ApplicationRecord
  # Validations — Rails checks these before saving to the DB
  validates :title,   presence: true, length: { minimum: 3, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :author,  presence: true, length: { minimum: 2, maximum: 100 }

  # Scopes — reusable, chainable query shortcuts
  scope :published,   -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :recent,      -> { order(created_at: :desc) }

  # Instance method — returns human-readable status
  def published_status
    published ? "Published" : "Draft"
  end
end
```

`ApplicationRecord` inherits from `ActiveRecord::Base`, which gives every
model automatic methods like `Article.find`, `Article.where`, `article.save`,
`article.destroy`, etc.

### `app/controllers/articles_controller.rb`

The **Controller** receives HTTP requests from the router and decides what
to do — query the database, redirect, or render a view.

| Action | HTTP verb + URL | What it does |
|--------|-----------------|--------------|
| `index` | GET `/articles` | List all articles |
| `show` | GET `/articles/:id` | Show one article |
| `new` | GET `/articles/new` | Display blank form |
| `create` | POST `/articles` | Save new article to DB |
| `edit` | GET `/articles/:id/edit` | Display pre-filled form |
| `update` | PATCH `/articles/:id` | Save changes to existing article |
| `destroy` | DELETE `/articles/:id` | Delete article from DB |

Key patterns used in this controller:

- **`before_action :set_article`** — runs `set_article` automatically before
  show, edit, update, destroy so you don't repeat `Article.find` in each action.
- **`respond_to`** — handles both HTML and JSON responses from the same action.
- **`params.expect`** — strong parameters; only allows whitelisted fields
  through, protecting against mass-assignment vulnerabilities.
- **`redirect_to` + `notice`** — after a successful action, sends the user
  somewhere else and shows a flash message.

### `app/views/`

Views are **ERB** templates (HTML with embedded Ruby, `.html.erb`).

- `<%= ... %>` — evaluates Ruby and outputs the result into the HTML
- `<% ... %>` — evaluates Ruby without outputting (used for loops, if-blocks)
- `<%= render "form", article: @article %>` — renders a **partial** (a reusable
  snippet of HTML, named with a leading underscore: `_form.html.erb`)

The `layouts/application.html.erb` file is the outer HTML shell — it includes
`<head>`, the navigation bar, and the footer. Every other view is inserted at
`<%= yield %>`.

### `app/assets/stylesheets/application.css`

Plain CSS for the entire application. No framework — just custom classes.
Key design conventions:

- CSS custom properties (`--black`, `--border`, etc.) defined in `:root`
- BEM-style naming: `.article-row`, `.article-row__title`, `.badge--published`
- Mobile-first responsive breakpoints at the bottom of the file

---

## `config/` — Configuration

```
config/
├── application.rb       ← Main app settings (timezone, autoload paths, etc.)
├── boot.rb              ← Boots Bundler before Rails loads
├── environment.rb       ← Loads the Rails application
├── routes.rb            ← URL routing rules ← IMPORTANT
├── environments/
│   ├── development.rb   ← Settings for local development (verbose logs, etc.)
│   ├── test.rb          ← Settings for the test environment
│   └── production.rb    ← Settings for production deployment
├── initializers/        ← Code that runs once on boot (e.g. configure gems)
├── locales/             ← Translation files for i18n
└── database.yml         ← Database connection settings per environment
```

### `config/routes.rb`

The router maps incoming HTTP requests to controller actions.

```ruby
Rails.application.routes.draw do
  resources :articles        # Generates all 7 RESTful routes automatically

  get "up" => "rails/health#show", as: :rails_health_check

  get "/favicon.ico", to: redirect("/icon.svg", status: 301)

  root "articles#index"      # "/" goes to ArticlesController#index
end
```

`resources :articles` is shorthand that generates these 7 routes:

```
GET    /articles          → articles#index
GET    /articles/new      → articles#new
POST   /articles          → articles#create
GET    /articles/:id      → articles#show
GET    /articles/:id/edit → articles#edit
PATCH  /articles/:id      → articles#update
DELETE /articles/:id      → articles#destroy
```

Run `bundle exec rails routes` to see every route in the app.

---

## `db/` — Database

```
db/
├── migrate/
│   ├── 20251011125253_create_articles.rb          ← Creates the articles table
│   └── 20260308131221_add_default_and_indexes_to_articles.rb ← Adds indexes + constraints
├── schema.rb             ← Auto-generated snapshot of the current DB structure
└── seeds.rb              ← Sample data loaded by `rails db:seed`
```

### How migrations work

Each file in `db/migrate/` is a **migration** — a versioned, reversible
description of a change to the database schema.

```ruby
# Simplified example of create_articles.rb
class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string  :title
      t.text    :content
      t.string  :author
      t.boolean :published, default: false, null: false
      t.timestamps           # adds created_at and updated_at automatically
    end
  end
end
```

Commands:

| Command | What it does |
|---------|--------------|
| `rails db:migrate` | Apply all pending migrations |
| `rails db:rollback` | Undo the last migration |
| `rails db:schema:load` | Build DB from schema.rb (faster than running all migrations) |
| `rails db:reset` | Drop, recreate, migrate, and seed |

### `db/schema.rb`

Auto-generated from your migrations. **Never edit this file by hand.**
It is the single source of truth for the current database structure.

### `db/seeds.rb`

Ruby code that creates starter data. Run with `rails db:seed`.
This project uses `find_or_create_by!` so running seeds twice is safe.

---

## `test/` — Automated Tests

```
test/
├── test_helper.rb                        ← Shared test setup
├── application_system_test_case.rb       ← Configures browser for system tests
├── fixtures/
│   └── articles.yml                      ← Sample data loaded for tests
├── models/
│   └── article_test.rb                   ← Tests for the Article model
├── controllers/
│   └── articles_controller_test.rb       ← Tests for HTTP request/response
└── system/
    └── articles_test.rb                  ← End-to-end browser tests (Selenium)
```

### Test types

| Type | File location | What it tests |
|------|--------------|---------------|
| **Model** | `test/models/` | Validations, scopes, methods |
| **Controller** (Integration) | `test/controllers/` | HTTP status codes, redirects, params |
| **System** | `test/system/` | Full browser flow (click, fill, assert) |

### Fixtures

`test/fixtures/articles.yml` defines **fixture records** — pre-built data
that is loaded into the test database before each test runs.

```yaml
one:
  title: First Article Title
  content: This is the content for the first article...
  author: John Doe
  published: true
```

Access in tests with: `articles(:one)` → returns the Article record.

Run tests:

```bash
bundle exec ruby -Itest test/models/article_test.rb
bundle exec ruby -Itest test/controllers/articles_controller_test.rb
```

---

## `public/` — Static Files

Files here are served directly by the web server, bypassing Rails entirely.

```
public/
├── icon.png        ← App icon (PNG fallback)
├── icon.svg        ← App icon (SVG, shown in browser tab)
├── robots.txt      ← Instructions for search engine crawlers
├── 404.html        ← Custom "Page not found" error page
├── 422.html        ← Custom "Unprocessable entity" error page
└── 500.html        ← Custom "Internal server error" error page
```

---

## `storage/` — Database Files

```
storage/
├── development.sqlite3   ← Your local development database
└── test.sqlite3          ← Separate database used only during tests
```

SQLite stores the entire database in a single file. In production, you would
replace this with PostgreSQL or MySQL by updating `config/database.yml`.

---

## `Gemfile` and `Gemfile.lock`

`Gemfile` lists the **gems** (Ruby libraries) the project depends on.

```ruby
gem "rails", "~> 8.1"       # The Rails framework
gem "sqlite3", ">= 2.1"     # Database adapter
gem "puma", ">= 5.0"        # Web server
gem "turbo-rails"            # Hotwire Turbo (fast page navigation)
gem "stimulus-rails"         # Hotwire Stimulus (lightweight JS)
gem "jbuilder"               # Build JSON responses with a Ruby DSL
gem "minitest", "~> 5.25"   # Test framework (pinned for Rails 8.1 compat)
```

`Gemfile.lock` records the exact version of every gem that was installed.
**Always commit both files.** The lock file ensures every developer gets
the same gem versions.

---

## `bin/` — Executable Scripts

```
bin/
├── rails     ← The main Rails CLI: `rails server`, `rails console`, etc.
├── bundle    ← Runs bundler in the context of this project
├── setup     ← Initial setup script (bundle install, db:prepare)
└── brakeman  ← Security scanner
```

Always prefix commands with `bundle exec` to use the project's exact gem
versions: `bundle exec rails server`.

---

## `docs/` — Documentation

```
docs/
├── PROJECT_STRUCTURE.md   ← This file — folder and file reference
├── TUTORIAL.md            ← Step-by-step Rails learning walkthrough
├── WINDOWS_GUIDE.md       ← Setup and run guide for Windows
├── LEARNING_ROADMAP.md    ← Features to implement for deeper learning
└── PROJECT_STATUS.md      ← History of changes made to this project
```

---

## `trash/` — Removed Files

Files that were removed from the project but kept for reference.

```
trash/
├── stylesheets/
│   ├── application.css.old       ← Old CSS backup
│   └── application.tailwind.css  ← Unused Tailwind config
├── pwa/
│   ├── manifest.json.erb         ← PWA manifest (routes disabled)
│   └── service-worker.js         ← PWA service worker (unused)
├── layouts/
│   ├── mailer.html.erb           ← Email layout (no mailers in project)
│   └── mailer.text.erb           ← Plain-text email layout
└── sqlite/
    ├── sqlite3.dll               ← Windows SQLite DLL (not needed in repo)
    ├── sqlite3.def               ← Windows export definition file
    └── sqlite.zip                ← Archive of the above
```

---

## Key Rails Concepts Illustrated in This Project

| Concept | Where to find it |
|---------|-----------------|
| MVC architecture | `app/models/`, `app/controllers/`, `app/views/` |
| RESTful routing | `config/routes.rb` |
| ActiveRecord ORM | `app/models/article.rb` |
| Validations | `app/models/article.rb` — `validates` calls |
| Scopes | `app/models/article.rb` — `scope` calls |
| Strong Parameters | `articles_controller.rb` — `article_params` |
| before_action | `articles_controller.rb` — `set_article` |
| Flash messages | `articles_controller.rb` — `notice:` in redirects |
| Partials | `app/views/articles/_form.html.erb` |
| ERB templates | `app/views/articles/*.html.erb` |
| Migrations | `db/migrate/` |
| Fixtures | `test/fixtures/articles.yml` |
| Responsive CSS | `app/assets/stylesheets/application.css` — `@media` blocks |
