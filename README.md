# Railpad

A Ruby on Rails 8 learning platform — write articles about Ruby and Rails, save
executable code snippets as Gists, and link them together.
Covers the full Rails stack: MVC, ActiveRecord, RESTful routing, validations,
scopes, testing, JSON API, and responsive UI.

---

## Features

| Feature | Details |
| ------- | ------- |
| Article CRUD | Create, read, update, delete via HTML and JSON API |
| Search | Full-text search across title, content, and author |
| Status filter | Filter by Published / Draft |
| Model validations | Presence and length rules enforced at model level |
| Scopes | `published`, `unpublished`, `recent` |
| Flash messages | Success and error notifications on every action |
| Delete confirmation | Turbo confirm dialog before destructive actions |
| JSON API | Full REST API at `/articles.json` |
| Responsive UI | Mobile, tablet, and desktop layouts |
| Automated tests | Model, controller (integration), and system tests |

---

## Technology Stack

| Layer | Technology |
| ----- | ---------- |
| Framework | Ruby on Rails 8.1 |
| Language | Ruby 3.4 |
| Database | SQLite3 |
| Asset pipeline | Propshaft |
| JavaScript | Hotwire (Turbo + Stimulus) |
| Styling | Custom CSS — Roboto font, monochrome design |
| Testing | Minitest 5.x |
| Web server | Puma |

---

## Prerequisites

- **Ruby 3.4** — [RubyInstaller for Windows](https://rubyinstaller.org/downloads/) (download the Devkit version)
- **Git** — [git-scm.com](https://git-scm.com/)
- SQLite3 is included via the `sqlite3` gem — no separate install needed

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/tanghoong/ror-cms.git
cd ror-cms

# 2. Install gems
bundle install

# 3. Set up the database
bundle exec rails db:create db:migrate db:seed

# 4. Start the server
bundle exec rails server
```

Open <http://localhost:3000> in your browser.

> **Windows users:** If `bundle` is not found, add Ruby to your PATH first:
>
> ```bash
> export PATH="/c/Ruby34-x64/bin:$PATH"
> ```
>
> See [docs/WINDOWS_GUIDE.md](docs/WINDOWS_GUIDE.md) for the full Windows setup guide.

---

## Project Structure

```text
ror-cms/
├── app/
│   ├── assets/stylesheets/application.css   ← All CSS (responsive, monochrome)
│   ├── controllers/articles_controller.rb   ← Handles HTTP requests
│   ├── models/article.rb                    ← Validations, scopes
│   └── views/
│       ├── articles/                        ← ERB templates
│       └── layouts/application.html.erb     ← Master HTML layout
├── config/
│   ├── routes.rb                            ← URL routing
│   └── environments/                        ← Dev / test / production settings
├── db/
│   ├── migrate/                             ← Schema change history
│   ├── schema.rb                            ← Current DB structure
│   └── seeds.rb                             ← Sample data
├── docs/                                    ← Learning documentation
├── public/                                  ← Static files (icons, error pages)
├── storage/                                 ← SQLite database files
├── test/                                    ← Automated test suite
├── Gemfile                                  ← Gem dependencies
└── Gemfile.lock                             ← Locked gem versions
```

Full reference: [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)

---

## Documentation

| Document | Description |
| -------- | ----------- |
| [docs/TUTORIAL.md](docs/TUTORIAL.md) | Step-by-step walkthrough of every Rails concept in this project |
| [docs/NEW_MODULE_GUIDE.md](docs/NEW_MODULE_GUIDE.md) | How to build a new CRUD module from scratch, step by step |
| [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) | Every folder and file explained |
| [docs/WINDOWS_GUIDE.md](docs/WINDOWS_GUIDE.md) | Full setup and daily workflow guide for Windows |
| [docs/LEARNING_ROADMAP.md](docs/LEARNING_ROADMAP.md) | 14 features to implement next, ordered by difficulty |

---

## Daily Commands

```bash
# Start the server
bundle exec rails server

# Windows: stop the current Rails PID and boot a fresh server
bin\restart_server.cmd

# Open the interactive Rails console
bundle exec rails console

# See all routes
bundle exec rails routes

# Run tests
bundle exec ruby -Itest test/models/article_test.rb
bundle exec ruby -Itest test/controllers/articles_controller_test.rb

# Apply new database migrations
bundle exec rails db:migrate

# Reset database (drops, recreates, migrates, seeds)
bundle exec rails db:reset
```

---

## REST API

| Method | URL | Description |
| ------ | --- | ----------- |
| GET | `/articles.json` | List all articles |
| GET | `/articles/:id.json` | Get one article |
| POST | `/articles.json` | Create article |
| PATCH | `/articles/:id.json` | Update article |
| DELETE | `/articles/:id.json` | Delete article |

```bash
# List all articles
curl http://localhost:3000/articles.json

# Create an article
curl -X POST http://localhost:3000/articles.json \
  -H "Content-Type: application/json" \
  -d '{"article":{"title":"API Test","content":"Content from the API endpoint.","author":"Dev","published":true}}'
```

---

## Model Validations

```text
Article
├── title    — required, 3–200 characters
├── content  — required, minimum 10 characters
├── author   — required, 2–100 characters
└── published — boolean, defaults to false
```

---

## Sample Data

Three articles are seeded by default (`bundle exec rails db:seed`):

| Title | Author | Status |
| ----- | ------ | ------ |
| Welcome to our CMS | Admin | Published |
| Getting Started with Rails | John Doe | Published |
| Draft Article | Jane Smith | Draft |

Re-running `db:seed` is safe — duplicates are prevented with `find_or_create_by!`.

---

## Running Tests

```bash
# Model tests (validations, scopes)
bundle exec ruby -Itest test/models/article_test.rb

# Controller tests (HTTP responses, filters)
bundle exec ruby -Itest test/controllers/articles_controller_test.rb
```

Expected output: **13 runs, 15 assertions, 0 failures, 0 errors**

---

## License

MIT — see [LICENSE](LICENSE).
