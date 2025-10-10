# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Categories API' do
  let!(:user) { create_user }
  let(:token) { login_user(user) }
  let(:headers) { auth_headers(token).merge('CONTENT_TYPE' => 'application/json') }

  describe 'GET /categories' do
    let!(:category1) { Category.create(name: 'Appetizers', sort_order: 1) }
    let!(:category2) { Category.create(name: 'Main Courses', sort_order: 2) }

    it 'returns paginated list of categories' do
      get '/categories', {}, auth_headers(token)

      expect(last_response.status).to eq(200)
      
      response = json_response
      expect(response[:data]).to be_an(Array)
      expect(response[:data].length).to eq(2)
      expect(response[:pagination]).to include(:page, :per_page, :total, :total_pages)
    end
  end

  describe 'GET /categories/tree' do
    let!(:parent_category) { Category.create(name: 'Food', sort_order: 1) }
    let!(:child_category) { Category.create(name: 'Pizza', parent_id: parent_category.id, sort_order: 1) }

    it 'returns category tree structure' do
      get '/categories/tree', {}, auth_headers(token)

      expect(last_response.status).to eq(200)
      
      response = json_response
      expect(response).to be_an(Array)
      expect(response.first[:name]).to eq('Food')
      expect(response.first[:subcategories].first[:name]).to eq('Pizza')
    end
  end

  describe 'POST /categories' do
    let(:category_data) do
      {
        name: 'Desserts',
        description: 'Sweet treats',
        sort_order: 3
      }
    end

    it 'creates a new category' do
      post '/categories', category_data.to_json, headers

      expect(last_response.status).to eq(201)
      
      response = json_response
      expect(response[:name]).to eq(category_data[:name])
      expect(response[:description]).to eq(category_data[:description])
    end

    it 'creates a subcategory' do
      parent = Category.create(name: 'Beverages', sort_order: 1)
      subcategory_data = category_data.merge(parent_id: parent.id)
      
      post '/categories', subcategory_data.to_json, headers

      expect(last_response.status).to eq(201)
      expect(json_response[:parent_id]).to eq(parent.id)
    end
  end

  describe 'PUT /categories/:id' do
    let!(:category) { Category.create(name: 'Old Name', sort_order: 1) }

    it 'updates an existing category' do
      update_data = { name: 'New Name', description: 'Updated description' }
      
      put "/categories/#{category.id}", update_data.to_json, headers

      expect(last_response.status).to eq(200)
      expect(json_response[:name]).to eq('New Name')
      expect(json_response[:description]).to eq('Updated description')
    end

    it 'returns 404 for non-existent category' do
      put '/categories/999', { name: 'Test' }.to_json, headers

      expect(last_response.status).to eq(404)
    end
  end

  describe 'DELETE /categories/:id' do
    let!(:category) { Category.create(name: 'Empty Category', sort_order: 1) }

    it 'deletes an empty category' do
      delete "/categories/#{category.id}", {}, auth_headers(token)

      expect(last_response.status).to eq(200)
      expect(json_response[:message]).to eq('Category deleted successfully')
    end

    it 'prevents deletion of category with products' do
      product = Product.create(name: 'Test Product', price: 10.0, category_id: category.id)
      
      delete "/categories/#{category.id}", {}, auth_headers(token)

      expect(last_response.status).to eq(422)
      expect(json_response[:error]).to include('Cannot delete category with products')
    end
  end
end