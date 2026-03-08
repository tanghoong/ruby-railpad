# Windows Development Guide — ror-cms

A beginner-friendly guide to setting up, running, and updating this Ruby on Rails CMS project on Windows. Written for learners who are new to Ruby and Rails.

---

## Table of Contents

1. [Prerequisites — What to Install](#1-prerequisites--what-to-install)
2. [First-Time Setup](#2-first-time-setup)
3. [Running the Server](#3-running-the-server)
4. [Stopping the Server](#4-stopping-the-server)
5. [Updating the Project](#5-updating-the-project)
6. [Useful Rails Commands](#6-useful-rails-commands)
7. [Project Structure Explained](#7-project-structure-explained)
8. [Learning Path — Rails Concepts in This Project](#8-learning-path--rails-concepts-in-this-project)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites — What to Install

Before you can run this project, you need to install the following tools.

### Ruby (with DevKit)

1. Go to [RubyInstaller for Windows](https://rubyinstaller.org/downloads/)
2. Download the **Ruby+Devkit** installer (e.g. `Ruby+Devkit 3.4.x (x64)`)
3. Run the installer — keep all defaults checked
4. At the end, a terminal window opens asking which components to install — type `1` and press Enter to install MSYS2 (required for native gems)
5. Verify the install by opening **Git Bash** or **Command Prompt** and running:

```bash
ruby --version
# Expected: ruby 3.4.x ...
```

### Git

1. Download from [git-scm.com](https://git-scm.com/)
2. Install with defaults
3. Verify:

```bash
git --version
```

### SQLite3 (already bundled)

SQLite3 is included via the `sqlite3` gem. No separate install is needed.

---

## 2. First-Time Setup

Open **Git Bash** (search for it in the Start Menu) and follow these steps.

### Step 1 — Clone the repository

```bash
git clone https://github.com/tanghoong/ror-cms.git
cd ror-cms
```

### Step 2 — Add Ruby to your PATH (if needed)

If `ruby` is not found, add it manually for the session:

```bash
export PATH="/c/Ruby34-x64/bin:$PATH"
```

To make this permanent, add the line above to your `~/.bashrc` file:

```bash
echo 'export PATH="/c/Ruby34-x64/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Step 3 — Install dependencies

`bundle install` reads the `Gemfile` and installs all required gems (libraries):

```bash
bundle install
```

This may take a few minutes the first time.

### Step 4 — Set up the database

These three commands create the database, apply migrations (table structures), and insert sample data:

```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

| Command | What it does |
|---|---|
| `db:create` | Creates the SQLite database files in `storage/` |
| `db:migrate` | Creates the tables defined in `db/migrate/` |
| `db:seed` | Inserts sample articles from `db/seeds.rb` |

You can also chain them all at once:

```bash
bundle exec rails db:create db:migrate db:seed
```

### Step 5 — Start the server

```bash
bundle exec rails server
```

Open your browser and visit: **http://localhost:3000**

---

## 3. Running the Server

Every time you come back to work on this project, open Git Bash and run:

```bash
cd /c/Users/<your-username>/Documents/GitHub/ror-cms
export PATH="/c/Ruby34-x64/bin:$PATH"
bundle exec rails server
```

You should see output like:

```
=> Booting Puma
=> Rails 8.1.1 application starting in development
* Listening on http://127.0.0.1:3000
Use Ctrl-C to stop
```

The server is now live at **http://localhost:3000**.

### Shortcut — create a startup script

Create a file called `start.sh` in the project root:

```bash
#!/bin/bash
export PATH="/c/Ruby34-x64/bin:$PATH"
bundle exec rails server
```

Then run it with:

```bash
bash start.sh
```

---

## 4. Stopping the Server

Press **Ctrl + C** in the terminal where the server is running.

---

## 5. Updating the Project

### Pull the latest code from GitHub

```bash
git pull origin main
```

### After pulling, always run these to stay in sync

```bash
bundle install          # Install any newly added gems
bundle exec rails db:migrate  # Apply any new database migrations
```

You do NOT need to run `db:seed` again after an update unless told to — it will duplicate the sample data.

### Full update checklist

```bash
git pull origin main
bundle install
bundle exec rails db:migrate
bundle exec rails server
```

---

## 6. Useful Rails Commands

These are the most important commands you will use while learning Rails.

### Server

```bash
bundle exec rails server          # Start the server (port 3000)
bundle exec rails server -p 4000  # Start on a different port
```

### Database

```bash
bundle exec rails db:migrate        # Apply pending migrations
bundle exec rails db:rollback       # Undo the last migration
bundle exec rails db:reset          # Drop, recreate, migrate, and seed
bundle exec rails db:schema:load    # Load schema directly (faster than migrate)
```

### Rails Console — interactive Ruby/Rails shell

```bash
bundle exec rails console
```

Inside the console you can run Ruby code against your live data:

```ruby
# Find all articles
Article.all

# Find published articles
Article.published

# Create a new article
Article.create(title: "My First Article", content: "Hello World content here", author: "Me", published: true)

# Find article by ID
Article.find(1)

# Count all articles
Article.count

# Exit the console
exit
```

### Routes — see all URL routes in the app

```bash
bundle exec rails routes
```

### Logs

The development log is at `log/development.log`. It shows every request and SQL query. You can watch it live in a second terminal:

```bash
tail -f log/development.log
```

### Tests

```bash
bundle exec rails test                                    # Run all tests
bundle exec rails test test/models/article_test.rb        # Run model tests only
bundle exec rails test test/controllers/                  # Run controller tests only
```

---

## 7. Project Structure Explained

```
ror-cms/
├── app/
│   ├── controllers/
│   │   └── articles_controller.rb   # Handles HTTP requests (index, show, new, create, edit, update, destroy)
│   ├── models/
│   │   └── article.rb               # Article data model + validations + scopes
│   └── views/
│       ├── articles/
│       │   ├── index.html.erb        # Article list page
│       │   ├── show.html.erb         # Single article page
│       │   ├── new.html.erb          # New article form page
│       │   ├── edit.html.erb         # Edit article form page
│       │   └── _form.html.erb        # Shared form partial (used by new and edit)
│       └── layouts/
│           └── application.html.erb  # Main HTML wrapper (nav, head, body)
│
├── config/
│   └── routes.rb                    # URL routing rules
│
├── db/
│   ├── migrate/                     # Database migration files (table definitions)
│   ├── schema.rb                    # Current database structure (auto-generated)
│   └── seeds.rb                     # Sample data loaded by db:seed
│
├── storage/
│   └── development.sqlite3          # Your local SQLite database file
│
├── Gemfile                          # List of gem (library) dependencies
├── Gemfile.lock                     # Exact locked versions of all gems
└── log/
    └── development.log              # Server request/response log
```

### Key Rails Concepts Used Here

| Concept | Where to find it |
|---|---|
| MVC (Model-View-Controller) | `app/models/`, `app/views/`, `app/controllers/` |
| RESTful routing | `config/routes.rb` |
| ActiveRecord (ORM) | `app/models/article.rb` |
| ERB templates | `app/views/articles/*.html.erb` |
| Validations | `app/models/article.rb` |
| Scopes | `app/models/article.rb` |
| Flash messages | `app/controllers/articles_controller.rb` |
| Partials | `app/views/articles/_form.html.erb` |
| Migrations | `db/migrate/` |

---

## 8. Learning Path — Rails Concepts in This Project

Use this project to study Rails concepts in this order:

### Level 1 — Understand the data

1. Read `db/schema.rb` — understand what columns the `articles` table has
2. Read `app/models/article.rb` — see how validations and scopes work
3. Open the Rails console and run `Article.all`, `Article.published`, `Article.count`

### Level 2 — Understand the routing

1. Run `bundle exec rails routes` and read the output
2. Read `config/routes.rb` — `resources :articles` generates all 7 RESTful routes automatically
3. Match each route to a method in `app/controllers/articles_controller.rb`

### Level 3 — Understand the controller

1. Read `app/controllers/articles_controller.rb`
2. Trace a single request: e.g., visiting `/articles` → `index` action → loads articles → renders `index.html.erb`
3. Look at how `params` is used to filter/search articles

### Level 4 — Understand the views

1. Read `app/views/layouts/application.html.erb` — the base HTML frame
2. Read `app/views/articles/index.html.erb` — how articles are looped and displayed
3. Read `app/views/articles/_form.html.erb` — how form fields map to model attributes

### Level 5 — Make changes

1. Add a new field to an article (e.g., `category`) — this requires a migration, model update, and view update
2. Add a new scope to the model (e.g., `scope :recent_published, -> { published.recent }`)
3. Add a new filter to the index action

---

## 9. Troubleshooting

### `ruby: command not found`

Ruby is not in your PATH. Run:

```bash
export PATH="/c/Ruby34-x64/bin:$PATH"
```

Then add this line to `~/.bashrc` to make it permanent.

### `bundle: command not found`

Same issue — Bundler is part of Ruby. Fix the PATH as above.

### `Could not find gem '...'`

Run `bundle install` again:

```bash
bundle install
```

### Port 3000 already in use

Either stop the other process using port 3000, or start Rails on a different port:

```bash
bundle exec rails server -p 3001
```

Then visit **http://localhost:3001**.

### Database errors / missing table

Run pending migrations:

```bash
bundle exec rails db:migrate
```

If the database is corrupted or missing, reset it entirely (this deletes all data):

```bash
bundle exec rails db:reset
```

### `Gemfile.lock` conflicts after `git pull`

Delete the lock file and reinstall:

```bash
rm Gemfile.lock
bundle install
```

### Check Rails version and environment info

```bash
bundle exec rails --version
bundle exec rails about
```

---

## Quick Reference Card

| Task | Command |
|---|---|
| Install gems | `bundle install` |
| Create & migrate DB | `bundle exec rails db:create db:migrate` |
| Seed sample data | `bundle exec rails db:seed` |
| Start server | `bundle exec rails server` |
| Open Rails console | `bundle exec rails console` |
| See all routes | `bundle exec rails routes` |
| Run all tests | `bundle exec rails test` |
| Pull latest code | `git pull origin main` |
| Apply new migrations | `bundle exec rails db:migrate` |
| Reset database | `bundle exec rails db:reset` |

---

*Happy learning! Rails follows "Convention over Configuration" — once you understand the patterns, everything clicks together.*
