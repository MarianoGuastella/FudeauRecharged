# frozen_string_literal: true

module ErrorHandlers
  def handle_json_parse_error
    yield
  rescue JSON::ParserError => e
    logger.warn "JSON Parse Error: #{e.message} - Request body malformed"
    status 400
    { error: "Invalid JSON format: #{e.message}" }.to_json
  end

  def handle_database_errors
    yield
  rescue Sequel::ValidationFailed => e
    logger.warn "Validation Error: #{e.message}"
    status 422
    { error: e.message }.to_json
  rescue Sequel::ForeignKeyConstraintViolation => e
    logger.warn "Foreign Key Constraint Violation: #{e.message}"
    status 422
    { error: "Foreign key constraint violation: #{e.message}" }.to_json
  rescue Sequel::UniqueConstraintViolation => e
    logger.warn "Unique Constraint Violation: #{e.message}"
    status 422
    { error: "Duplicate entry: #{e.message}" }.to_json
  rescue Sequel::DatabaseError => e
    logger.error "Database Error: #{e.message} - #{e.backtrace.first(3).join(', ')}"
    status 500
    { error: "Database error: #{e.message}" }.to_json
  end

  def handle_authentication_errors
    yield
  rescue Sequel::ValidationFailed => e
    logger.warn "Authentication Validation Error: #{e.message}"
    status 422
    { error: e.message }.to_json
  rescue BCrypt::Errors::InvalidSecret, BCrypt::Errors::InvalidHash => e
    logger.error "BCrypt Authentication Error: #{e.message}"
    status 500
    { error: 'Authentication system error' }.to_json
  rescue Sequel::DatabaseError => e
    logger.error "Authentication Database Error: #{e.message} - #{e.backtrace.first(3).join(', ')}"
    status 500
    { error: 'Database error during authentication' }.to_json
  end
end
