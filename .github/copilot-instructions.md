# Copilot Instructions for ror-cms

## Project Overview
A Ruby on Rails 8 CMS built for article management with modern frontend technologies. Features CRUD operations for articles with JSON API support and demonstrates Rails' latest conventions.

## Architecture & Key Components

### Technology Stack
- **Rails 8.0.3** with Ruby 3.2.3 
- **Frontend**: Tailwind CSS + Slim templating + Hotwire (Turbo/Stimulus)
- **Database**: SQLite3 with Solid Cache/Queue/Cable for production
- **Testing**: Minitest with Capybara system tests
- **Deployment**: Docker + Kamal with Thruster for production

### Data Model
Simple Article model with fields: `title`, `content`, `author`, `published` (boolean)
- Located in `app/models/article.rb` (currently minimal)
- Migration in `db/migrate/20251011125253_create_articles.rb`

### Routing & Controllers
- Root route: `articles#index` (replaces traditional home page)
- RESTful articles resource with dual format support (HTML/JSON)
- Controllers follow Rails conventions with strong parameters
- JSON API responses via JBuilder templates

## Development Workflow

### Essential Commands
```bash
# Setup (runs bundle install, db:prepare, starts dev server)
bin/setup

# Development server (just Rails server)
bin/dev

# Full development with CSS watching
# Use Procfile.dev: web + css processes
foreman start -f Procfile.dev

# Database management
bin/rails db:prepare  # Create/migrate/seed
bin/rails db:migrate
bin/rails db:seed

# Testing
bin/rails test        # All tests
bin/rails test:system # System tests only

# Code quality
bin/rubocop          # Linting (Omakase Ruby styling)
bin/brakeman         # Security analysis
```

### File Structure Patterns
- **Views**: Mix of ERB (`articles/`) and Slim (`home/index.html.slim`)
- **Styling**: Tailwind classes in templates, config in `config/tailwind.config.js`
- **Assets**: Modern Rails asset pipeline with Propshaft
- **Tests**: Standard Rails test structure with fixtures

## Project-Specific Conventions

### Frontend Approach
- **Slim templates preferred** for new views (see `app/views/home/index.html.slim`)
- **Tailwind utility classes** for styling (configured for Slim/ERB)
- **No JavaScript framework** - uses Rails' Hotwire stack
- **Responsive design** with Tailwind's responsive prefixes

### Code Style (Omakase Ruby)
- Uses `rubocop-rails-omakase` gem for opinionated Ruby styling
- Configuration in `.rubocop.yml` inherits from omakase defaults
- Enforces Rails community standards automatically

### Testing Strategy
- **Minitest** (not RSpec) - Rails default testing framework
- **Fixtures** in `test/fixtures/articles.yml` for test data
- **System tests** using headless Chrome for full-stack testing
- **Parallel test execution** enabled by default

### Deployment & Production
- **Docker-first** deployment strategy with multi-stage Dockerfile
- **Kamal** configuration in `config/deploy.yml` for container orchestration
- **Thruster** for production HTTP acceleration (replaces nginx)
- **Solid gems** (Cache/Queue/Cable) replace Redis dependencies

## Integration Points

### JSON API Design
- All controller actions support `.json` format via `respond_to`
- JBuilder templates in `app/views/articles/*.json.jbuilder`
- Consistent error handling for both HTML and JSON responses

### Asset Pipeline
- **Tailwind CSS** compilation via `tailwindcss:watch` task
- **Propshaft** for asset serving (modern replacement for Sprockets)
- **Importmap** for JavaScript module management

### Security Configuration
- Rails credentials system for secrets (`config/credentials.yml.enc`)
- Strong parameters pattern enforced in controllers
- CSRF protection enabled by default

## Development Tips

### When Adding Features
1. Use Rails generators: `bin/rails generate model/controller/migration`
2. Follow RESTful conventions for new resources
3. Add both HTML and JSON format support to controllers
4. Include appropriate tests for new functionality
5. Use Tailwind classes for styling, avoid custom CSS

### Common Patterns
- **Controller actions**: Always include `respond_to` block for dual format support
- **Strong parameters**: Use `params.expect()` for parameter handling (Rails 8 syntax)
- **View helpers**: Place in `app/helpers/` following Rails conventions
- **Model validations**: Add appropriate validations and consider database constraints
