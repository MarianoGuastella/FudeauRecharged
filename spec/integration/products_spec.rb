# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Products API' do
  let!(:user) { create_user }
  let(:token) { login_user(user) }
  let(:headers) { auth_headers(token).merge('CONTENT_TYPE' => 'application/json') }
  let!(:category) { Category.create(name: 'Test Category', sort_order: 1) }

  describe 'GET /products' do
    let!(:product1) { Product.create(name: 'Product 1', price: 10.50, category_id: category.id) }
    let!(:product2) { Product.create(name: 'Product 2', price: 15.00, category_id: category.id, available: false) }

    it 'returns paginated list of products' do
      get '/products', {}, auth_headers(token)

      expect(last_response.status).to eq(200)

      response = json_response
      expect(response[:data]).to be_an(Array)
      expect(response[:data].length).to eq(2)
    end

    it 'filters by category' do
      other_category = Category.create(name: 'Other Category', sort_order: 2)
      Product.create(name: 'Other Product', price: 20.0, category_id: other_category.id)

      get '/products', { category_id: category.id }, auth_headers(token)

      expect(last_response.status).to eq(200)
      expect(json_response[:data].length).to eq(2)
    end

    it 'filters by availability' do
      # Asegurar que solo tenemos nuestros productos de prueba
      get '/products', { available: 'true', category_id: category.id }, auth_headers(token)

      expect(last_response.status).to eq(200)
      expect(json_response[:data].length).to eq(1)
      expect(json_response[:data].first[:available]).to be true
      expect(json_response[:data].first[:name]).to eq('Product 1')
    end
  end

  describe 'GET /products/:id' do
    let!(:product) { Product.create(name: 'Test Product', price: 12.99, category_id: category.id) }

    it 'returns product details with associations' do
      get "/products/#{product.id}", {}, auth_headers(token)

      expect(last_response.status).to eq(200)

      response = json_response
      expect(response[:name]).to eq('Test Product')
      expect(response[:price]).to eq('12.99')
      expect(response[:category]).to include(:id, :name)
    end

    it 'returns 404 for non-existent product' do
      get '/products/999', {}, auth_headers(token)

      expect(last_response.status).to eq(404)
    end
  end

  describe 'POST /products' do
    let(:product_data) do
      {
        name: 'New Product',
        description: 'A delicious new item',
        price: 25.99,
        category_id: category.id,
        image_url: 'https://example.com/image.jpg',
      }
    end

    it 'creates a new product' do
      post '/products', product_data.to_json, headers

      expect(last_response.status).to eq(201)

      response = json_response
      expect(response[:name]).to eq(product_data[:name])
      expect(response[:price]).to eq('25.99')
      expect(response[:category_id]).to eq(category.id)
    end

    it 'validates required fields' do
      invalid_data = product_data.except(:name, :price)

      post '/products', invalid_data.to_json, headers

      expect(last_response.status).to eq(422)
    end

    it 'validates price is positive' do
      invalid_data = product_data.merge(price: -5.0)

      post '/products', invalid_data.to_json, headers

      expect(last_response.status).to eq(422)
    end
  end

  describe 'PUT /products/:id' do
    let!(:product) { Product.create(name: 'Old Name', price: 10.0, category_id: category.id) }

    it 'updates an existing product' do
      update_data = { name: 'Updated Name', price: 15.50 }

      put "/products/#{product.id}", update_data.to_json, headers

      expect(last_response.status).to eq(200)
      expect(json_response[:name]).to eq('Updated Name')
      expect(json_response[:price]).to eq('15.5')
    end
  end

  describe 'DELETE /products/:id' do
    let!(:product) { Product.create(name: 'Test Product', price: 10.0, category_id: category.id) }

    it 'deletes a product' do
      delete "/products/#{product.id}", {}, auth_headers(token)

      expect(last_response.status).to eq(200)
      expect(json_response[:message]).to eq('Product deleted successfully')
    end

    it 'prevents deletion of product used in modifiers' do
      modifier = ProductModifier.create(
        name: 'Test Modifier',
        product_id: product.id,
        min_selections: 0,
        max_selections: 1,
      )
      other_product = Product.create(name: 'Other Product', price: 5.0, category_id: category.id)
      ProductModifierOption.create(
        product_modifier_id: modifier.id,
        product_id: other_product.id,
        additional_price: 0.0,
      )

      delete "/products/#{other_product.id}", {}, auth_headers(token)

      expect(last_response.status).to eq(422)
      expect(json_response[:error]).to include('Cannot delete product that is used as a modifier option')
    end
  end
end
