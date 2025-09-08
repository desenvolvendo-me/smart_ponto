# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Smart Ponto is a Rails 8.0 time tracking application that manages employee time entries, time sheets, and approval workflows. The system uses Devise for authentication and includes features for time registration, approval processes, CSV/Excel exports, and justification management.

## Core Architecture

### Models and Domain Logic
- **User**: Authenticated users with Devise, can be employees or approvers
- **TimeEntry**: Individual clock-in/out records with types ('entrada', 'saída') and statuses ('registrado', 'aprovado', 'rejeitado')
- **TimeSheet**: Daily aggregated view of time entries with approval workflow and justification system
- **UserPreference**: User-specific settings

### Key Business Rules
- TimeEntries automatically associate with TimeSheets by date
- TimeSheets calculate total hours from paired entry/exit records
- Tolerance system: 15-minute variance from 8-hour workday before justification required
- Approval workflow: 'pendente' → 'enviado' → 'aprovado'/'rejeitado'
- Justification workflow: 'sem_justificativa' → 'pendente' → 'aprovada'/'rejeitada'

### Controllers Structure
- `DashboardController`: Main landing page after authentication
- `TimeEntriesController`: Individual time record management with quick registration
- `TimeSheetsController`: Daily time sheet management, approvals, exports, calendar view
- `ApprovalsController`: Manager approval interface
- `UserPreferencesController`: User settings management

## Development Commands

### Rails Standard Commands
```bash
# Start development server
bin/rails server
# or with Foreman (includes live reload)
foreman start

# Database operations  
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset

# Console access
bin/rails console

# Run tests (RSpec)
bundle exec rspec
# Run specific test file
bundle exec rspec spec/models/time_entry_spec.rb

# Code quality
bundle exec rubocop
bundle exec brakeman
```

### Asset Management
```bash
# Compile assets
bin/rails assets:precompile

# TailwindCSS compilation (via tailwindcss-rails gem)
bin/rails tailwindcss:build
```

## Key Features and Routes

### Time Tracking
- `/meu-ponto` - TimeSheets management (Portuguese paths)
- `/registros` - TimeEntries management  
- Quick registration via AJAX for real-time clock-in/out

### Approval Workflow
- `/approvals` - Manager interface for approving time sheets
- Time sheets require submission (`submit_for_approval`) before approval
- Signature system for approved time sheets

### Export Functionality
- CSV export via `TimeSheet.to_csv`
- Excel export via caxlsx gem integration
- Date range filtering for exports

### Calendar Integration
- Calendar view for time sheet overview
- Date-based navigation and filtering

## Database Schema Notes

- Uses SQLite3 with Solid Queue, Solid Cache, and Solid Cable
- Separate schemas for main app, queue, and cache (see config files)
- Key indices on date fields for performance

## Authentication & Authorization

- Devise handles user authentication
- Custom approval hierarchy (approvers can approve other users' time sheets)
- Root route redirects to dashboard for authenticated users

## Testing Setup

- RSpec for testing framework  
- Factory Bot for test data
- Database Cleaner for test isolation
- Capybara + Selenium for system tests
- Shoulda Matchers for Rails-specific assertions

## Dependencies & Integrations

- **Kaminari**: Pagination
- **Ransack**: Search and filtering
- **Rufus Scheduler**: Background job scheduling
- **caxlsx/caxlsx_rails**: Excel export functionality
- **TailwindCSS**: Styling framework
- **Stimulus/Turbo**: JavaScript framework (Rails 8 defaults)

## Code Style

- Uses rubocop-rails-omakase for Ruby style guidelines
- Inherits Omakase configuration with minimal customization