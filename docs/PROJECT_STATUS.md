# Project Status (as of 2026-03-08)

## What This App Does
- Ruby on Rails 8 CMS for managing articles.
- Supports full article CRUD via HTML and JSON.
- Root route is the articles index with search and status filtering.

## What Has Been Done
- Implemented `Article` CRUD (`resources :articles`).
- Added model validations:
  - `title`: presence, length 3..200
  - `content`: presence, minimum length 10
  - `author`: presence, length 2..100
- Added article scopes:
  - `published`
  - `unpublished`
  - `recent`
- Added index filtering:
  - text search across `title`, `content`, `author`
  - status filter for `published` and `draft`
- Added safer search pattern handling with `sanitize_sql_like`.
- Implemented modernized UI styling and improved article index/show/forms.
- Added tests for:
  - model validations and scopes
  - controller CRUD and filtering endpoints
  - system CRUD flow

## Maintenance Update Completed in This Session
- Updated `.gitignore` to ignore local stash/backup artifacts:
  - `*.stash`
  - `stash-*.patch`
  - `*.orig`
  - `*.rej`
  - `*.bak`
  - `*.swp`
  - `*.swo`
  - `*~`
- Verified branch sync with remote:
  - `main...origin/main` ahead/behind = `0/0`
- Installed missing gems with `bundle install`.
- Confirmed dependency state with `bundle check`.
- Ran test command (`bin/rails test`) successfully (exit code `0`).

## What To Do Next (Priority)
1. Add DB-level constraints for data integrity.
   - Set `articles.published` to `null: false, default: false`.
2. Improve search performance as data grows.
   - Add indexes (e.g., `published`, maybe `created_at`).
3. Strengthen tests for filtering correctness.
   - Assert expected records in/out, not only success responses.
4. Clean up stack consistency.
   - Remove or integrate unused Tailwind/Slim `home` artifacts.
5. Add authentication/authorization if this is intended for real CMS usage.
6. Add pagination to `articles#index`.
