# frozen_string_literal: true

module AuthRoutes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_auth_routes
      post '/auth/register' do
        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_authentication_errors do
            user = User.create(data)
            logger.info "User registered: #{user.email}"
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
                logger.info "Login success: #{user.email}"
                token = generate_jwt_token(user)
                { user: user.to_hash_with_associations, token: token }.to_json
              else
                logger.warn "Login failed - deactivated account: #{data[:email]}"
                status 403
                { error: 'Account is deactivated' }.to_json
              end
            else
              logger.warn "Login failed - invalid credentials: #{data[:email]}"
              status 401
              { error: 'Invalid email or password' }.to_json
            end
          end
        end
      end

      get '/auth/me' do
        authenticate!
        current_user.to_hash_with_associations.to_json
      end
    end
  end
end
