# frozen_string_literal: true

module AuthRoutes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_auth_routes
      # Auth endpoints
      post '/auth/register' do
        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_authentication_errors do
            user = User.create(data)
            logger.info "New user registered - ID: #{user.id}, Email: #{user.email}"
            status 201
            { user: user.to_hash_with_associations }.to_json
          end
        end
      end

      post '/auth/login' do
        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_authentication_errors do
            user = User.where(email: data[:email]).first
            if user&.authenticate?(data[:password])
              if user.active
                logger.info "Successful login for user ID: #{user.id}"
                # Generate authentication token
                token = generate_jwt_token(user)
                { user: user.to_hash_with_associations, token: token }.to_json
              else
                logger.warn "Login attempt for deactivated account - Email: #{data[:email]}"
                status 403
                { error: 'Account is deactivated' }.to_json
              end
            else
              logger.warn "Failed login attempt - Email: #{data[:email]}"
              status 401
              { error: 'Invalid email or password' }.to_json
            end
          end
        end
      end

      get '/auth/me' do
        if request.env['HTTP_AUTHORIZATION']
          token = request.env['HTTP_AUTHORIZATION'].sub(/^Bearer\s+/, '')
          user_id = decode_jwt_token(token)
          if user_id
            user = User[user_id]
            if user
              user.to_hash_with_associations.to_json
            else
              (halt 401, { error: 'Invalid token' }.to_json)
            end
          else
            halt 401, { error: 'Invalid token' }.to_json
          end
        else
          status 401
          { error: 'Missing authorization token' }.to_json
        end
      end
    end
  end
end
