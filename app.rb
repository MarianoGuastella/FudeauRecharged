# frozen_string_literal: true

require 'sinatra/base'
require 'dotenv/load'
require 'json'
require 'logger'

# Load models
require_relative 'app/models/user'
require_relative 'app/models/category'
require_relative 'app/models/product'
require_relative 'app/models/product_modifier'
require_relative 'app/models/product_modifier_option'

# Load helpers
require_relative 'app/helpers/error_handlers'
require_relative 'app/helpers/authentication_helpers'

# Load routes
require_relative 'app/routes/auth_routes'
require_relative 'app/routes/product_routes'
require_relative 'app/routes/category_routes'
require_relative 'app/routes/menu_routes'

class RestaurantAPI < Sinatra::Base
  include ErrorHandlers
  include AuthenticationHelpers
  include AuthRoutes
  include ProductRoutes
  include CategoryRoutes
  include MenuRoutes

  configure do
    set :show_exceptions, false
    set :raise_errors, false
    set :logging, true
    
    # Configure logger
    logger = Logger.new(STDOUT)
    logger.level = ENV['LOG_LEVEL']&.upcase == 'DEBUG' ? Logger::DEBUG : Logger::INFO
    logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
    end
    set :logger, logger
  end

  before do
    content_type :json
  end

  # Register route modules
  register_auth_routes
  register_product_routes
  register_category_routes
  register_menu_routes

  # Health check endpoint
  get '/health' do
    { status: 'ok', timestamp: Time.now.iso8601 }.to_json
  end

  # 404 handler
  not_found do
    { error: 'Endpoint not found', status: 404 }.to_json
  end
end