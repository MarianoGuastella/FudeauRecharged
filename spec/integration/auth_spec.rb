# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Auth API' do
  describe 'POST /auth/register' do
    let(:user_data) do
      {
        email: "test-user-#{Time.now.to_f}@example.com",
        password: 'password123',
        name: 'New User'
      }
    end

    it 'creates a new user successfully' do
      post '/auth/register', user_data.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(201)
      
      response = json_response
      expect(response[:user][:email]).to eq(user_data[:email])
      expect(response[:user][:name]).to eq(user_data[:name])
      expect(response[:user]).not_to have_key(:password_hash)
    end

    it 'returns error for invalid email' do
      invalid_data = user_data.merge(email: 'invalid-email')
      
      post '/auth/register', invalid_data.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(422)
      expect(json_response[:error]).to eq('email is invalid')
    end

    it 'returns error for duplicate email' do
      first_user_data = {
        email: user_data[:email],
        password: 'password123',
        name: 'First User'
      }
      post '/auth/register', first_user_data.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(201)
      
      post '/auth/register', user_data.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(422)
      expect(json_response[:error]).to include('email is already taken')
    end
  end

  describe 'POST /auth/login' do
    let!(:user) { create_user }

    it 'logs in user with valid credentials' do
      post '/auth/login', {
        email: user.email,
        password: 'password123'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      
      response = json_response
      expect(response[:user][:email]).to eq(user.email)
      expect(response[:token]).not_to be_nil
      expect(response[:token]).not_to be_empty
    end

    it 'returns error for invalid credentials' do
      post '/auth/login', {
        email: user.email,
        password: 'wrongpassword'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(401)
      expect(json_response[:error]).to eq('Invalid email or password')
    end

    it 'returns error for inactive user' do
      user.update(active: false)
      
      post '/auth/login', {
        email: user.email,
        password: 'password123'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(403)
      expect(json_response[:error]).to eq('Account is deactivated')
    end
  end

  describe 'GET /auth/me' do
    let!(:user) { create_user }
    let(:token) { login_user(user) }

    it 'returns current user info with valid token' do
      get '/auth/me', {}, auth_headers(token)

      expect(last_response.status).to eq(200)
      expect(json_response[:email]).to eq(user.email)
    end

    it 'returns error without token' do
      get '/auth/me'

      expect(last_response.status).to eq(401)
      expect(json_response[:error]).to include('Missing authorization token')
    end
  end
end