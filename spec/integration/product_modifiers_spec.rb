# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Product Modifiers API' do
  let!(:user) { create_user }
  let(:token) { login_user(user) }
  let(:headers) { auth_headers(token).merge('CONTENT_TYPE' => 'application/json') }
  let!(:category) { Category.create(name: 'Test Category', sort_order: 1) }
  let!(:product) { Product.create(name: 'Test Product', price: 10.0, category_id: category.id) }

  describe 'GET /product-modifiers' do
    let!(:modifier1) do
      ProductModifier.create(name: 'Size', product_id: product.id, min_selections: 1, max_selections: 1)
    end
    let!(:modifier2) do
      ProductModifier.create(name: 'Toppings', product_id: product.id, min_selections: 0, max_selections: 3)
    end

    it 'returns paginated list of product modifiers' do
      get '/product-modifiers', {}, auth_headers(token)

      expect(last_response.status).to eq(200)
      response = json_response
      expect(response[:data]).to be_an(Array)
      expect(response[:data].length).to eq(2)
      expect(response[:pagination]).to include(:page, :per_page, :total, :total_pages)
    end

    it 'filters modifiers by product_id' do
      other_product = Product.create(name: 'Other Product', price: 15.0, category_id: category.id)
      ProductModifier.create(name: 'Other Modifier', product_id: other_product.id, min_selections: 0, max_selections: 1)

      get '/product-modifiers', { product_id: product.id }, auth_headers(token)

      expect(last_response.status).to eq(200)
      response = json_response
      expect(response[:data].length).to eq(2)
      response[:data].each do |modifier|
        expect(modifier[:product][:id]).to eq(product.id)
      end
    end

    it 'includes product information and options count' do
      get '/product-modifiers', {}, auth_headers(token)

      response = json_response
      modifier = response[:data].first
      expect(modifier[:product]).to include(:id, :name)
      expect(modifier).to have_key(:options_count)
    end
  end

  describe 'GET /product-modifiers/:id' do
    let!(:modifier) do
      ProductModifier.create(name: 'Size', description: 'Choose size', product_id: product.id, min_selections: 1,
                             max_selections: 1)
    end
    let!(:topping_product) { Product.create(name: 'Cheese', price: 1.5, can_be_sold_separately: false) }
    let!(:option) do
      ProductModifierOption.create(product_modifier_id: modifier.id, product_id: topping_product.id,
                                   additional_price: 1.5)
    end

    it 'returns modifier details with options' do
      get "/product-modifiers/#{modifier.id}", {}, auth_headers(token)

      expect(last_response.status).to eq(200)
      response = json_response
      expect(response[:name]).to eq('Size')
      expect(response[:description]).to eq('Choose size')
      expect(response[:product]).to include(:id, :name, :category)
      expect(response[:options]).to be_an(Array)
      expect(response[:options].length).to eq(1)

      option_data = response[:options].first
      expect(option_data[:product][:name]).to eq('Cheese')
      expect(option_data[:additional_price]).to eq('1.50')
    end

    it 'returns 404 for non-existent modifier' do
      get '/product-modifiers/999', {}, auth_headers(token)

      expect(last_response.status).to eq(404)
    end
  end

  describe 'POST /product-modifiers' do
    let(:modifier_data) do
      {
        name: 'Toppings',
        description: 'Choose your toppings',
        product_id: product.id,
        required: false,
        min_selections: 0,
        max_selections: 3,
      }
    end

    it 'creates a new product modifier' do
      post '/product-modifiers', modifier_data.to_json, headers

      expect(last_response.status).to eq(201)
      response = json_response
      expect(response[:name]).to eq('Toppings')
      expect(response[:product][:id]).to eq(product.id)
      expect(response[:options]).to eq([])
    end

    it 'validates required fields' do
      invalid_data = modifier_data.except(:name, :product_id)

      post '/product-modifiers', invalid_data.to_json, headers

      expect(last_response.status).to eq(422)
      expect(json_response[:error]).to include('Missing required fields')
    end

    it 'validates product exists' do
      invalid_data = modifier_data.merge(product_id: 999)

      post '/product-modifiers', invalid_data.to_json, headers

      expect(last_response.status).to eq(422)
      expect(json_response[:error]).to eq('Product not found')
    end

    it 'validates selection constraints' do
      invalid_data = modifier_data.merge(min_selections: 5, max_selections: 3)

      post '/product-modifiers', invalid_data.to_json, headers

      expect(last_response.status).to eq(422)
      expect(json_response[:error]).to eq('Invalid selection constraints')
    end
  end

  describe 'PUT /product-modifiers/:id' do
    let!(:modifier) do
      ProductModifier.create(name: 'Size', product_id: product.id, min_selections: 1, max_selections: 1)
    end

    it 'updates an existing modifier' do
      update_data = { name: 'Updated Size', max_selections: 2 }

      put "/product-modifiers/#{modifier.id}", update_data.to_json, headers

      expect(last_response.status).to eq(200)
      response = json_response
      expect(response[:name]).to eq('Updated Size')
      expect(response[:max_selections]).to eq(2)
    end

    it 'validates new product exists when changing product_id' do
      update_data = { product_id: 999 }

      put "/product-modifiers/#{modifier.id}", update_data.to_json, headers

      expect(last_response.status).to eq(422)
      expect(json_response[:error]).to eq('Product not found')
    end
  end

  describe 'DELETE /product-modifiers/:id' do
    let!(:modifier) do
      ProductModifier.create(name: 'Size', product_id: product.id, min_selections: 1, max_selections: 1)
    end
    let!(:topping_product) { Product.create(name: 'Cheese', price: 1.5, can_be_sold_separately: false) }
    let!(:option) do
      ProductModifierOption.create(product_modifier_id: modifier.id, product_id: topping_product.id,
                                   additional_price: 1.5)
    end

    it 'deletes a modifier and its options' do
      delete "/product-modifiers/#{modifier.id}", {}, auth_headers(token)

      expect(last_response.status).to eq(200)
      expect(json_response[:message]).to eq('Product modifier deleted successfully')

      # Verify modifier and options are deleted
      expect(ProductModifier[modifier.id]).to be_nil
      expect(ProductModifierOption.where(product_modifier_id: modifier.id).count).to eq(0)
    end
  end

  describe 'Modifier Options endpoints' do
    let!(:modifier) do
      ProductModifier.create(name: 'Toppings', product_id: product.id, min_selections: 0, max_selections: 3)
    end
    let!(:cheese) { Product.create(name: 'Cheese', price: 1.5, can_be_sold_separately: false) }
    let!(:bacon) { Product.create(name: 'Bacon', price: 2.0, can_be_sold_separately: false) }

    describe 'GET /product-modifiers/:modifier_id/options' do
      let!(:option1) do
        ProductModifierOption.create(product_modifier_id: modifier.id, product_id: cheese.id, additional_price: 1.5)
      end
      let!(:option2) do
        ProductModifierOption.create(product_modifier_id: modifier.id, product_id: bacon.id, additional_price: 2.0)
      end

      it 'returns options for a modifier' do
        get "/product-modifiers/#{modifier.id}/options", {}, auth_headers(token)

        expect(last_response.status).to eq(200)
        response = json_response
        expect(response[:data].length).to eq(2)

        cheese_option = response[:data].find { |opt| opt[:product][:name] == 'Cheese' }
        expect(cheese_option[:additional_price]).to eq('1.50')
      end
    end

    describe 'POST /product-modifiers/:modifier_id/options' do
      it 'creates a new modifier option' do
        option_data = {
          product_id: cheese.id,
          additional_price: 1.5,
          default_selected: false,
        }

        post "/product-modifiers/#{modifier.id}/options", option_data.to_json, headers

        expect(last_response.status).to eq(201)
        response = json_response
        expect(response[:product][:name]).to eq('Cheese')
        expect(response[:additional_price]).to eq('1.50')
      end

      it 'prevents duplicate options for same product' do
        ProductModifierOption.create(product_modifier_id: modifier.id, product_id: cheese.id, additional_price: 1.5)

        option_data = { product_id: cheese.id, additional_price: 2.0 }

        post "/product-modifiers/#{modifier.id}/options", option_data.to_json, headers

        expect(last_response.status).to eq(422)
        expect(json_response[:error]).to include('Option for this product already exists')
      end
    end

    describe 'PUT /product-modifiers/:modifier_id/options/:option_id' do
      let!(:option) do
        ProductModifierOption.create(product_modifier_id: modifier.id, product_id: cheese.id, additional_price: 1.5)
      end

      it 'updates an existing option' do
        update_data = { additional_price: 2.0, default_selected: true }

        put "/product-modifiers/#{modifier.id}/options/#{option.id}", update_data.to_json, headers

        expect(last_response.status).to eq(200)
        response = json_response
        expect(response[:additional_price]).to eq('2.00')
        expect(response[:default_selected]).to be true
      end
    end

    describe 'DELETE /product-modifiers/:modifier_id/options/:option_id' do
      let!(:option) do
        ProductModifierOption.create(product_modifier_id: modifier.id, product_id: cheese.id, additional_price: 1.5)
      end

      it 'deletes a modifier option' do
        delete "/product-modifiers/#{modifier.id}/options/#{option.id}", {}, auth_headers(token)

        expect(last_response.status).to eq(200)
        expect(json_response[:message]).to eq('Modifier option deleted successfully')
        expect(ProductModifierOption[option.id]).to be_nil
      end
    end
  end
end
