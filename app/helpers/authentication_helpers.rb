# frozen_string_literal: true

module AuthenticationHelpers
  # Authentication token methods
  def generate_jwt_token(user)
    # Simple token implementation for all environments
    if ENV['RACK_ENV'] == 'test'
      "test-token-#{user.id}"
    else
      "token-#{user.id}-#{Time.now.to_i}"
    end
  end

  def decode_jwt_token(token)
    # Simple token parsing for all environments
    if ENV['RACK_ENV'] == 'test'
      # Extract user_id from test token format: "test-token-{user_id}"
      match = token.match(/^test-token-(\d+)$/)
      if match
        match[1].to_i
      else
        logger.warn "Invalid test token format: #{token}"
        nil
      end
    else
      # Simple token format: "token-{user_id}-{timestamp}"
      match = token.match(/^token-(\d+)-\d+$/)
      if match
        match[1].to_i
      else
        logger.warn "Invalid token format: #{token}"
        nil
      end
    end
  end
end
