# How to Create a New Module (Resource) in Rails

This guide teaches you the exact steps a Rails developer follows to add a
brand-new CRUD feature — without generators, without AI — so you understand
every decision being made.

We will build a **Category** module as the worked example. By the end, users
can create, read, update, and delete categories through both the browser UI
and the JSON API.

---

## The Mental Model First

Before touching any file, answer three questions:

| Question | Example answer |
| -------- | -------------- |
| **What data do I need to store?** | Category name and optional description |
| **What are the rules (validations)?** | Name: required, 2–50 chars. Name must be unique. |
| **Does this connect to anything else?** | Later — articles will belong to a category |

Once you can answer these, you know exactly what to build.

---

## Overview of Steps

```
1. Migration  → creates the database table
2. Model      → defines rules (validations, scopes, associations)
3. Routes     → maps URLs to controller actions
4. Controller → handles HTTP requests and calls the model
5. Views      → HTML templates the user sees
6. JSON views → API responses (jbuilder)
7. Tests      → verifies everything works correctly
8. Seeds      → adds sample data
```

Work in this order every time. Each layer depends on the one above it.

---

## Step 1 — Write the Migration

A migration is a Ruby file that changes the database structure.
It lives in `db/migrate/`.

**Create the file** at `db/migrate/YYYYMMDDHHMMSS_create_categories.rb`.

The filename timestamp must be unique — use the current date and time.
Example: `20260310120000_create_categories.rb`

```ruby
class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string  :name,        null: false
      t.text    :description
      t.timestamps                        # adds created_at and updated_at
    end

    add_index :categories, :name, unique: true
  end
end
```

**Column type reference:**

| Type | Ruby | Stores |
| ---- | ---- | ------ |
| `string` | `t.string :name` | Short text (≤ 255 chars) |
| `text` | `t.text :description` | Long text (unlimited) |
| `integer` | `t.integer :count` | Whole numbers |
| `boolean` | `t.boolean :active` | true / false |
| `datetime` | `t.datetime :published_at` | Date + time |
| `references` | `t.references :article` | Foreign key (belongs_to) |

**Run the migration:**

```bash
bundle exec rails db:migrate
```

Rails reads the timestamp, runs only new migrations, and updates `db/schema.rb`
automatically. Never edit `schema.rb` by hand.

**Verify it worked:**

```bash
bundle exec rails db:migrate:status
```

You should see `up` next to your migration.

---

## Step 2 — Write the Model

Create `app/models/category.rb`.

```ruby
class Category < ApplicationRecord
  # ── Validations ────────────────────────────────────────────
  validates :name, presence: true,
                   length: { minimum: 2, maximum: 50 },
                   uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true

  # ── Scopes ─────────────────────────────────────────────────
  scope :alphabetical, -> { order(:name) }

  # ── Instance methods ───────────────────────────────────────
  def display_name
    name.capitalize
  end
end
```

**Rules for writing validations:**

- `presence: true` — field cannot be blank
- `length: { minimum: N, maximum: N }` — character limits
- `uniqueness: true` — no duplicates in the database
- `allow_blank: true` — skip validation if field is empty (for optional fields)
- `numericality: { greater_than: 0 }` — for number fields

**Test the model immediately in the Rails console:**

```bash
bundle exec rails console
```

```ruby
# Should succeed
Category.create!(name: "Technology", description: "Tech articles")

# Should fail — name too short
c = Category.new(name: "X")
c.valid?                    # → false
c.errors.full_messages      # → ["Name is too short (minimum is 2 characters)"]

# Should fail — duplicate name
Category.create!(name: "Technology")   # → raises ActiveRecord::RecordInvalid

Category.count              # → 1
Category.alphabetical       # → all categories A–Z
```

If the console confirms the rules work, move to the next step.

---

## Step 3 — Add the Routes

Open `config/routes.rb` and add one line:

```ruby
Rails.application.routes.draw do
  resources :articles
  resources :categories          # ← add this

  root "articles#index"
end
```

`resources :categories` generates all 7 RESTful routes at once:

```
GET    /categories          → categories#index   (list all)
GET    /categories/new      → categories#new     (blank form)
POST   /categories          → categories#create  (save new)
GET    /categories/:id      → categories#show    (view one)
GET    /categories/:id/edit → categories#edit    (edit form)
PATCH  /categories/:id      → categories#update  (save changes)
DELETE /categories/:id      → categories#destroy (delete)
```

Verify with:

```bash
bundle exec rails routes | grep categor
```

You should see all 7 rows listed.

---

## Step 4 — Write the Controller

Create `app/controllers/categories_controller.rb`.

This is the longest file. Write each action in order.

```ruby
class CategoriesController < ApplicationController
  before_action :set_category, only: %i[show edit update destroy]

  # GET /categories
  def index
    @categories = Category.alphabetical.load
  end

  # GET /categories/1
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /categories/1
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: "Category was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy!

    respond_to do |format|
      format.html { redirect_to categories_path, notice: "Category was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_category
    @category = Category.find(params.expect(:id))
  end

  def category_params
    params.expect(category: [:name, :description])
  end
end
```

**Controller checklist — ask yourself these questions:**

| Question | Answer for categories |
| -------- | --------------------- |
| Which actions need `@category` loaded first? | show, edit, update, destroy |
| What fields are safe to accept from forms? | name, description |
| Where does the user go after create? | The new category's show page |
| Where does the user go after destroy? | The categories index page |
| Does this need search/filter? | Not yet — add later if needed |

---

## Step 5 — Write the Views

You need these files inside `app/views/categories/`:

```
_form.html.erb     ← shared form (used by new + edit)
index.html.erb     ← list all categories
show.html.erb      ← view one category
new.html.erb       ← page wrapper for create form
edit.html.erb      ← page wrapper for edit form
```

Create each file now.

### `app/views/categories/_form.html.erb`

The shared form. Both new and edit pages render this partial.

```erb
<div class="form-container">
  <%= form_with(model: category) do |form| %>
    <% if category.errors.any? %>
      <div class="alert-errors">
        <h2><%= pluralize(category.errors.count, "error") %> prohibited this category from being saved:</h2>
        <ul>
          <% category.errors.each do |error| %>
            <li><%= error.full_message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div class="form-group">
      <%= form.label :name, class: "form-label" %>
      <%= form.text_field :name, class: "form-control", placeholder: "Category name..." %>
    </div>

    <div class="form-group">
      <%= form.label :description, class: "form-label" %>
      <%= form.text_area :description, class: "form-control", placeholder: "Optional description...", rows: 4 %>
    </div>

    <div class="form-group">
      <%= form.submit class: "btn btn-primary" %>
    </div>
  <% end %>
</div>
```

### `app/views/categories/new.html.erb`

```erb
<% content_for :title, "New Category" %>

<div class="page-header">
  <h1>New Category</h1>
</div>

<%= render "form", category: @category %>

<div class="nav-actions">
  <%= link_to "Back to categories", categories_path, class: "btn btn-secondary" %>
</div>
```

### `app/views/categories/edit.html.erb`

```erb
<% content_for :title, "Edit Category" %>

<div class="page-header">
  <h1>Edit Category</h1>
</div>

<%= render "form", category: @category %>

<div class="nav-actions">
  <%= link_to "Back to category", @category, class: "btn btn-secondary" %>
  <%= link_to "All categories", categories_path, class: "btn btn-secondary" %>
</div>
```

### `app/views/categories/show.html.erb`

```erb
<% content_for :title, @category.name %>

<div class="article-detail">
  <div class="article-detail-header">
    <h1 class="article-detail-title"><%= @category.name %></h1>
  </div>

  <% if @category.description.present? %>
    <div class="article-detail-content">
      <%= simple_format(@category.description) %>
    </div>
  <% end %>
</div>

<div class="nav-actions">
  <%= link_to "Edit", edit_category_path(@category), class: "btn btn-secondary" %>
  <%= link_to "All categories", categories_path, class: "btn btn-secondary" %>
  <%= button_to "Delete", @category, method: :delete,
      class: "btn btn-danger",
      form: { data: { turbo_confirm: "Delete this category?" } } %>
</div>
```

### `app/views/categories/index.html.erb`

```erb
<% content_for :title, "Categories" %>

<div class="page-header">
  <h1>Categories</h1>
  <div class="page-header__meta"><%= @categories.size %> <%= "category".pluralize(@categories.size) %></div>
</div>

<% if @categories.any? %>
  <table class="article-list">
    <thead>
      <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Created</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <% @categories.each do |category| %>
        <tr class="article-row">
          <td class="article-row__title" data-label="Name">
            <%= link_to category.name, category %>
          </td>
          <td data-label="Description"><%= truncate(category.description.to_s, length: 80) %></td>
          <td class="article-row__date" data-label="Created"><%= category.created_at.strftime("%d %b %Y") %></td>
          <td class="article-row__actions">
            <%= link_to "Edit", edit_category_path(category), class: "btn btn-ghost btn-sm" %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
<% else %>
  <div class="empty-state">
    <p>No categories yet.</p>
    <%= link_to "+ Create your first category", new_category_path, class: "btn btn-primary" %>
  </div>
<% end %>

<div class="nav-actions">
  <%= link_to "+ New Category", new_category_path, class: "btn btn-primary" %>
</div>
```

---

## Step 6 — Write the JSON Views (API)

These are optional but make your module a proper API too.
Create them in `app/views/categories/`.

### `app/views/categories/_category.json.jbuilder`

```ruby
json.extract! category, :id, :name, :description, :created_at, :updated_at
json.url category_url(category, format: :json)
```

### `app/views/categories/index.json.jbuilder`

```ruby
json.array! @categories, partial: "categories/category", as: :category
```

### `app/views/categories/show.json.jbuilder`

```ruby
json.partial! "categories/category", category: @category
```

**Test the JSON API:**

```bash
# List all categories
curl http://localhost:3000/categories.json

# Show one
curl http://localhost:3000/categories/1.json

# Create
curl -X POST http://localhost:3000/categories.json \
  -H "Content-Type: application/json" \
  -d '{"category":{"name":"Technology","description":"Tech articles"}}'

# Update
curl -X PATCH http://localhost:3000/categories/1.json \
  -H "Content-Type: application/json" \
  -d '{"category":{"name":"Tech"}}'

# Delete
curl -X DELETE http://localhost:3000/categories/1.json
```

---

## Step 7 — Write the Tests

Tests live in `test/`. Write two files.

### `test/fixtures/categories.yml`

Fixtures define pre-built data loaded before each test.

```yaml
technology:
  name: Technology
  description: All things tech and software.

travel:
  name: Travel
  description: Places and adventures.
```

### `test/models/category_test.rb`

Test the model rules in isolation.

```ruby
require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  # ── Validation tests ──────────────────────────────────────

  test "is valid with a name" do
    category = Category.new(name: "Technology")
    assert category.valid?
  end

  test "is invalid without a name" do
    category = Category.new(name: "")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "is invalid when name is too short" do
    category = Category.new(name: "X")
    assert_not category.valid?
  end

  test "is invalid when name is too long" do
    category = Category.new(name: "A" * 51)
    assert_not category.valid?
  end

  test "is invalid with a duplicate name" do
    Category.create!(name: "Technology")
    duplicate = Category.new(name: "Technology")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "duplicate check is case-insensitive" do
    Category.create!(name: "Technology")
    duplicate = Category.new(name: "technology")
    assert_not duplicate.valid?
  end

  test "description is optional" do
    category = Category.new(name: "Tech")
    assert category.valid?
  end

  # ── Scope tests ───────────────────────────────────────────

  test "alphabetical scope orders by name" do
    cat_b = categories(:travel)     # loaded from fixtures
    cat_a = categories(:technology)
    result = Category.alphabetical
    assert result.first.name <= result.last.name
  end
end
```

### `test/controllers/categories_controller_test.rb`

Test HTTP responses — does each URL return the right status code?

```ruby
require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:technology)
  end

  test "should get index" do
    get categories_url
    assert_response :success
  end

  test "should get new" do
    get new_category_url
    assert_response :success
  end

  test "should create category" do
    assert_difference("Category.count") do
      post categories_url, params: { category: { name: "Science", description: "Science topics" } }
    end
    assert_redirected_to category_url(Category.last)
  end

  test "should not create category with invalid data" do
    assert_no_difference("Category.count") do
      post categories_url, params: { category: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should show category" do
    get category_url(@category)
    assert_response :success
  end

  test "should get edit" do
    get edit_category_url(@category)
    assert_response :success
  end

  test "should update category" do
    patch category_url(@category), params: { category: { name: "Updated Tech" } }
    assert_redirected_to category_url(@category)
  end

  test "should not update category with invalid data" do
    patch category_url(@category), params: { category: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy category" do
    assert_difference("Category.count", -1) do
      delete category_url(@category)
    end
    assert_redirected_to categories_url
  end
end
```

**Run the tests:**

```bash
bundle exec ruby -Itest test/models/category_test.rb
bundle exec ruby -Itest test/controllers/categories_controller_test.rb
```

All tests should pass with 0 failures, 0 errors.

---

## Step 8 — Add Seed Data

Open `db/seeds.rb` and add sample categories.
Always use `find_or_create_by!` so running seeds twice is safe.

```ruby
# Existing articles seed ...

[
  { name: "Technology",  description: "Software, hardware, and programming." },
  { name: "Travel",      description: "Places to visit and adventures to take." },
  { name: "General",     description: "Everything else." }
].each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |c|
    c.description = attrs[:description]
  end
end

puts "Seeded #{Category.count} categories."
```

**Run seeds:**

```bash
bundle exec rails db:seed
```

---

## Step 9 — Verify Everything Works

Open your browser and check each URL manually:

| URL | Expected result |
| --- | --------------- |
| `http://localhost:3000/categories` | List of categories |
| `http://localhost:3000/categories/new` | Blank form |
| Submit the form | Redirects to show page, flash notice appears |
| `http://localhost:3000/categories/1/edit` | Pre-filled form |
| Submit edits | Redirects to show, updated data visible |
| Delete button | Confirm dialog, then redirects to list |
| `http://localhost:3000/categories.json` | JSON array |

If anything is broken, read the Rails server log — it shows the exact error,
file, and line number.

---

## Summary — The Complete Checklist

Copy this and tick each box as you work:

```
□ 1. Plan: decide fields, validations, and relationships
□ 2. Migration: create db/migrate/TIMESTAMP_create_RESOURCE.rb
□ 3. Run: bundle exec rails db:migrate
□ 4. Model: create app/models/RESOURCE.rb with validates + scopes
□ 5. Console: test model rules in rails console
□ 6. Routes: add resources :RESOURCE to config/routes.rb
□ 7. Verify: bundle exec rails routes | grep RESOURCE
□ 8. Controller: create app/controllers/RESOURCES_controller.rb
             — before_action, index, show, new, create, edit, update, destroy
             — private set_RESOURCE, RESOURCE_params
□ 9. Views: create app/views/RESOURCE/
             — _form.html.erb
             — index.html.erb
             — show.html.erb
             — new.html.erb
             — edit.html.erb
□ 10. JSON views: _RESOURCE.json.jbuilder, index.json.jbuilder, show.json.jbuilder
□ 11. Fixtures: test/fixtures/RESOURCES.yml
□ 12. Model tests: test/models/RESOURCE_test.rb
□ 13. Controller tests: test/controllers/RESOURCES_controller_test.rb
□ 14. Run tests: bundle exec ruby -Itest test/...
□ 15. Seeds: add sample data to db/seeds.rb, run rails db:seed
□ 16. Manual browser check: all 7 URLs work correctly
```

---

## Common Mistakes and How to Fix Them

| Mistake | Symptom | Fix |
| ------- | ------- | --- |
| Forgot to run migration | `SQLite3::Exception: no such table: categories` | `rails db:migrate` |
| Typo in model class name | `NameError: uninitialized constant` | Filename = snake_case, class = CamelCase |
| Wrong partial name | `Missing partial categories/_category` | File must start with `_` |
| Missing field in `category_params` | Field silently not saved | Add field name to the whitelist array |
| Fixture references wrong model | `KeyError in test` | Fixtures file must match model name (plural) |
| Tests use wrong fixture key | `NoMethodError` | Check the key name in `.yml` matches the test |
| `resources` not added to routes | `NameError: undefined local variable categories_path` | Add `resources :categories` to routes.rb |

---

## Naming Conventions Rails Enforces

Rails maps names automatically — you must follow these conventions or things break silently.

| Thing | Convention | Example |
| ---- | ---------- | ------- |
| Database table | plural, snake_case | `categories` |
| Model class | singular, CamelCase | `Category` |
| Model file | singular, snake_case | `app/models/category.rb` |
| Controller class | plural, CamelCase + Controller | `CategoriesController` |
| Controller file | plural, snake_case | `app/controllers/categories_controller.rb` |
| Views folder | plural, snake_case | `app/views/categories/` |
| Route helper (list) | plural | `categories_path` |
| Route helper (one) | singular | `category_path(@category)` |
| Fixtures file | plural, snake_case | `test/fixtures/categories.yml` |

---

## Next Steps After CRUD Works

Once your module is fully working, these are the natural next additions:

1. **Add a nav link** — add `Categories` to the navigation in `app/views/layouts/application.html.erb`
2. **Add a relationship** — connect categories to articles with `belongs_to` / `has_many`
3. **Add pagination** — use the Pagy gem to page through long lists
4. **Add search** — filter by name in the index action
5. **Add sorting** — let users click column headers to sort

Each of these follows the same pattern: read the docs for what you need,
understand why the change goes where it does, and follow the MVC layers.

---

## Reference — Rails Command Quick Look-up

```bash
# See all routes
bundle exec rails routes

# Filter routes by keyword
bundle exec rails routes | grep categor

# Open the Rails console
bundle exec rails console

# Run a specific migration
bundle exec rails db:migrate

# Check migration status
bundle exec rails db:migrate:status

# Roll back the last migration (undo it)
bundle exec rails db:rollback

# Run model tests
bundle exec ruby -Itest test/models/category_test.rb

# Run controller tests
bundle exec ruby -Itest test/controllers/categories_controller_test.rb

# Reseed the database
bundle exec rails db:seed
```
