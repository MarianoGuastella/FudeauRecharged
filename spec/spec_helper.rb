# frozen_string_literal: true

require 'rspec'
require 'rack/test'
require 'json'

ENV['RACK_ENV'] = 'test'

# Load database configuration first
require_relative '../config/database'

# Run migrations for test database BEFORE loading models
require_relative '../lib/migrate'
MigrationRunner.run!

# Now load the app
require_relative '../app'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) do
    # Clean database before each test
    # Disable foreign key checks temporarily
    DB.run('PRAGMA foreign_keys = OFF')

    tables_to_clear = [
      'product_modifier_options',
      'product_modifiers',
      'products',
      'categories',
      'users',
    ]

    tables_to_clear.each do |table|
      DB[table.to_sym].delete if DB.table_exists?(table.to_sym)
    end

    # Re-enable foreign key checks
    DB.run('PRAGMA foreign_keys = ON')
  end

  def app
    RestaurantAPI
  end

  # Helper methods
  def json_response
    JSON.parse(last_response.body, symbolize_names: true)
  end

  def create_user(email: nil, password: 'password123', name: 'Test User')
    unique_email = email || "test#{Time.now.to_f}@example.com"
    User.create(
      email: unique_email,
      password: password,
      name: name,
    )
  end

  def login_user(user)
    post '/auth/login', {
      email: user.email,
      password: 'password123',
    }.to_json, { 'CONTENT_TYPE' => 'application/json' }

    json_response[:token]
  end

  def auth_headers(token)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end
end
