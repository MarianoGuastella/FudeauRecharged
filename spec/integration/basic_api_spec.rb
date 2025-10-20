# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Basic API Tests' do
  describe 'GET /health' do
    it 'returns health status' do
      get '/health'

      expect(last_response.status).to eq(200)
      response = json_response
      expect(response[:status]).to eq('ok')
      expect(response[:timestamp]).not_to be_nil
    end
  end

  describe 'Auth API' do
    describe 'POST /auth/register' do
      it 'creates a new user successfully' do
        user_data = {
          email: "test-user-#{Time.now.to_f}@example.com",
          password: 'password123',
          name: 'New User',
        }

        post '/auth/register', user_data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(201)
        response = json_response
        expect(response[:user][:email]).to eq(user_data[:email])
        expect(response[:user][:name]).to eq(user_data[:name])
        expect(response[:user]).not_to have_key(:password_hash)
      end
    end

    describe 'POST /auth/login' do
      it 'logs in user with valid credentials' do
        user_data = {
          email: 'loginuser@example.com',
          password: 'password123',
          name: 'Login User',
        }
        post '/auth/register', user_data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        login_data = {
          email: user_data[:email],
          password: user_data[:password],
        }
        post '/auth/login', login_data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(200)
        response = json_response
        expect(response[:user][:email]).to eq(user_data[:email])
        expect(response[:token]).not_to be_nil
      end

      it 'returns error for invalid credentials' do
        login_data = {
          email: 'nonexistent@example.com',
          password: 'wrongpassword',
        }
        post '/auth/login', login_data.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(401)
        response = json_response
        expect(response[:error]).to eq('Invalid email or password')
      end
    end
  end

  describe 'Categories API' do
    describe 'GET /categories' do
      it 'returns list of categories' do
        get '/categories'

        expect(last_response.status).to eq(200)
        response = json_response
        expect(response[:data]).to be_an(Array)
      end
    end

    describe 'POST /categories' do
      it 'creates a new category' do
        user = create_user
        token = login_user(user)

        category_data = {
          name: 'Test Category',
          description: 'A test category',
          sort_order: 1,
        }

        post '/categories', category_data.to_json, { 'CONTENT_TYPE' => 'application/json' }.merge(auth_headers(token))

        expect(last_response.status).to eq(201)
        response = json_response
        expect(response[:name]).to eq(category_data[:name])
        expect(response[:description]).to eq(category_data[:description])
      end
    end
  end

  describe 'Products API' do
    before do
      @category = Category.create(name: 'Test Category', sort_order: 1)
    end

    describe 'GET /products' do
      it 'returns list of products' do
        get '/products'

        expect(last_response.status).to eq(200)
        response = json_response
        expect(response[:data]).to be_an(Array)
      end
    end

    describe 'POST /products' do
      it 'creates a new product' do
        user = create_user
        token = login_user(user)

        product_data = {
          name: 'Test Product',
          description: 'A test product',
          price: 12.99,
          category_id: @category.id,
        }

        post '/products', product_data.to_json, { 'CONTENT_TYPE' => 'application/json' }.merge(auth_headers(token))

        expect(last_response.status).to eq(201)
        response = json_response
        expect(response[:name]).to eq(product_data[:name])
        expect(response[:description]).to eq(product_data[:description])
        expect(response[:category_id]).to eq(@category.id)
      end
    end
  end
end
