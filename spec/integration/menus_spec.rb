# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Menus API' do
  let!(:user) { create_user }
  let(:token) { login_user(user) }

  before do
    # Create test menu structure
    @beverages = Category.create(name: 'Beverages', sort_order: 1)
    @hot_drinks = Category.create(name: 'Hot Drinks', parent_id: @beverages.id, sort_order: 1)
    @cold_drinks = Category.create(name: 'Cold Drinks', parent_id: @beverages.id, sort_order: 2)

    @food = Category.create(name: 'Food', sort_order: 2)
    @burgers = Category.create(name: 'Burgers', parent_id: @food.id, sort_order: 1)

    @coffee = Product.create(name: 'Coffee', price: 3.50, category_id: @hot_drinks.id)
    @soda = Product.create(name: 'Soda', price: 2.50, category_id: @cold_drinks.id)
    @burger = Product.create(name: 'Classic Burger', price: 12.99, category_id: @burgers.id)

    # Modifiers
    @toppings = ProductModifier.create(
      name: 'Toppings',
      description: 'Choose your toppings',
      product_id: @burger.id,
      min_selections: 0,
      max_selections: 3,
    )

    @cheese = Product.create(name: 'Cheese', price: 1.50, can_be_sold_separately: false)
    @bacon = Product.create(name: 'Bacon', price: 2.00, can_be_sold_separately: false)

    ProductModifierOption.create(
      product_modifier_id: @toppings.id,
      product_id: @cheese.id,
      additional_price: 1.50,
    )

    ProductModifierOption.create(
      product_modifier_id: @toppings.id,
      product_id: @bacon.id,
      additional_price: 2.00,
    )
  end

  describe 'GET /menus' do
    it 'returns complete menu structure' do
      get '/menus', {}, auth_headers(token)

      expect(last_response.status).to eq(200)

      response = json_response
      expect(response[:menu]).to have_key(:categories)

      categories = response[:menu][:categories]
      expect(categories.length).to eq(2)

      # Check beverages category
      beverages = categories.find { |c| c[:name] == 'Beverages' }
      expect(beverages).not_to be_nil
      expect(beverages[:subcategories].length).to eq(2)

      hot_drinks = beverages[:subcategories].find { |c| c[:name] == 'Hot Drinks' }
      expect(hot_drinks[:products].length).to eq(1)
      expect(hot_drinks[:products].first[:name]).to eq('Coffee')

      # Check food category
      food = categories.find { |c| c[:name] == 'Food' }
      expect(food).not_to be_nil

      burgers = food[:subcategories].find { |c| c[:name] == 'Burgers' }
      burger_product = burgers[:products].first

      expect(burger_product[:name]).to eq('Classic Burger')
      expect(burger_product[:modifiers].length).to eq(1)

      toppings_modifier = burger_product[:modifiers].first
      expect(toppings_modifier[:name]).to eq('Toppings')
      expect(toppings_modifier[:options].length).to eq(2)

      cheese_option = toppings_modifier[:options].find { |o| o[:product][:name] == 'Cheese' }
      expect(cheese_option[:additional_price]).to eq('1.5')
    end
  end

  describe 'GET /menus/categories/:id' do
    it 'returns specific category menu' do
      get "/menus/categories/#{@burgers.id}", {}, auth_headers(token)

      expect(last_response.status).to eq(200)

      response = json_response
      expect(response[:name]).to eq('Burgers')
      expect(response[:products].length).to eq(1)

      burger = response[:products].first
      expect(burger[:name]).to eq('Classic Burger')
      expect(burger[:modifiers].length).to eq(1)
    end

    it 'returns 404 for non-existent category' do
      get '/menus/categories/999', {}, auth_headers(token)

      expect(last_response.status).to eq(404)
    end
  end

  describe 'menu structure validation' do
    it 'includes all required product fields' do
      get '/menus', {}, auth_headers(token)

      response = json_response
      burger = response[:menu][:categories]
               .find { |c| c[:name] == 'Food' }[:subcategories]
               .find { |c| c[:name] == 'Burgers' }[:products]
               .first

      expect(burger).to include(:id, :name, :description, :price, :image_url, :can_be_sold_separately, :modifiers)
    end

    it 'includes all required modifier fields' do
      get '/menus', {}, auth_headers(token)

      response = json_response
      modifier = response[:menu][:categories]
                 .find { |c| c[:name] == 'Food' }[:subcategories]
                 .find { |c| c[:name] == 'Burgers' }[:products]
                 .first[:modifiers]
                 .first

      expect(modifier).to include(:id, :name, :description, :required, :min_selections, :max_selections, :options)
    end

    it 'includes all required modifier option fields' do
      get '/menus', {}, auth_headers(token)

      response = json_response
      option = response[:menu][:categories]
               .find { |c| c[:name] == 'Food' }[:subcategories]
               .find { |c| c[:name] == 'Burgers' }[:products]
               .first[:modifiers]
               .first[:options]
               .first

      expect(option).to include(:id, :product, :additional_price, :default_selected)
      expect(option[:product]).to include(:id, :name, :description)
    end
  end
end
