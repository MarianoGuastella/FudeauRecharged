# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.0.2'

# Web framework
gem 'sinatra', '~> 3.0'
gem 'sinatra-contrib', '~> 3.0'

# Database
gem 'sqlite3', '~> 1.6'
gem 'sequel', '~> 5.70'

# Authentication
gem 'bcrypt', '~> 3.1'
gem 'jwt', '~> 2.7'

# JSON handling
gem 'multi_json', '~> 1.15'

# HTTP server
gem 'puma', '~> 6.3'

# Environment variables
gem 'dotenv', '~> 2.8'

# Validations
gem 'dry-validation', '~> 1.10'

group :development, :test do
  gem 'rspec', '~> 3.12'
  gem 'rack-test', '~> 2.1'
  gem 'factory_bot', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'rubocop', '~> 1.56'
  gem 'rubocop-rspec', '~> 2.23'
end

group :development do
  gem 'rerun', '~> 0.14'
end