# frozen_string_literal: true

require 'jwt'

module AuthenticationHelpers
  JWT_SECRET = ENV.fetch('JWT_SECRET', 'your-secret-key-change-in-production')
  JWT_ALGORITHM = 'HS256'
  TOKEN_EXPIRATION = 24 * 60 * 60

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: Time.now.to_i + TOKEN_EXPIRATION,
      iat: Time.now.to_i,
    }

    JWT.encode(payload, JWT_SECRET, JWT_ALGORITHM)
  end

  def decode_jwt_token(token)
    decoded = JWT.decode(token, JWT_SECRET, true, { algorithm: JWT_ALGORITHM })
    payload = decoded.first
    payload['user_id']
  rescue JWT::ExpiredSignature, JWT::DecodeError
    nil
  rescue StandardError => e
    logger.error "Unexpected error decoding JWT: #{e.message}"
    nil
  end

  def authenticate!
    auth_header = request.env['HTTP_AUTHORIZATION']
    halt 401, { error: 'Missing authorization token' }.to_json unless auth_header

    token = auth_header.sub(/^Bearer\s+/, '')
    user_id = decode_jwt_token(token)
    halt 401, { error: 'Invalid or expired token' }.to_json unless user_id

    user = User[user_id]
    halt 401, { error: 'User not found' }.to_json unless user
    halt 403, { error: 'Account is deactivated' }.to_json unless user.active

    @current_user = user
  end

  def current_user
    @current_user
  end
end
