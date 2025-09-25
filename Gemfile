source "https://rubygems.org"

gem "rails", "~> 8.0.0"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

gem "kaminari"
gem 'ransack'
gem "foreman"
gem "tailwindcss-rails"

gem "devise"
gem 'rufus-scheduler'
gem 'csv'
gem 'caxlsx'           # Para exportação Excel
gem 'caxlsx_rails'     # Integração Rails com caxlsx

group :development, :test do
  gem "hotwire-spark"
  gem 'better_errors'
  gem 'binding_of_caller'
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem 'rspec-rails'
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
end

group :development do
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers'
end
