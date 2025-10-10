#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../app'

# Seed data for development and testing
class SeedData
  def self.create!
    puts 'Creating seed data...'

    # Create admin user
    admin_email = ENV['ADMIN_EMAIL'] || 'admin@restaurant.com'
    admin_password = ENV['ADMIN_PASSWORD'] || 'admin123'

    admin = User.create(
      email: admin_email,
      password: admin_password,
      name: 'Restaurant Admin',
    )
    puts "Created admin user: #{admin.email}"

    # Create categories
    beverages = Category.create(name: 'Beverages', description: 'Drinks and refreshments', sort_order: 1)
    hot_drinks = Category.create(name: 'Hot Drinks', parent_id: beverages.id, sort_order: 1)
    cold_drinks = Category.create(name: 'Cold Drinks', parent_id: beverages.id, sort_order: 2)

    food = Category.create(name: 'Food', description: 'Main dishes and snacks', sort_order: 2)
    appetizers = Category.create(name: 'Appetizers', parent_id: food.id, sort_order: 1)
    main_courses = Category.create(name: 'Main Courses', parent_id: food.id, sort_order: 2)
    burgers = Category.create(name: 'Burgers', parent_id: main_courses.id, sort_order: 1)
    pizza = Category.create(name: 'Pizza', parent_id: main_courses.id, sort_order: 2)
    desserts = Category.create(name: 'Desserts', description: 'Sweet treats', sort_order: 3)

    puts 'Created categories'

    # Create beverages
    Product.create(
      name: 'Coffee',
      description: 'Freshly brewed coffee',
      price: 3.50,
      category_id: hot_drinks.id,
    )

    Product.create(
      name: 'Tea',
      description: 'Selection of fine teas',
      price: 3.00,
      category_id: hot_drinks.id,
    )

    Product.create(
      name: 'Soft Drink',
      description: 'Coca-Cola, Pepsi, Sprite',
      price: 2.50,
      category_id: cold_drinks.id,
    )

    Product.create(
      name: 'Fresh Juice',
      description: 'Orange, Apple, or Mixed Berry',
      price: 4.00,
      category_id: cold_drinks.id,
    )

    # Create appetizers
    Product.create(
      name: 'Buffalo Wings',
      description: 'Spicy chicken wings with blue cheese dip',
      price: 9.99,
      category_id: appetizers.id,
    )

    Product.create(
      name: 'Loaded Nachos',
      description: 'Tortilla chips with cheese, jalapeños, and salsa',
      price: 8.50,
      category_id: appetizers.id,
    )

    # Create main courses - burgers
    classic_burger = Product.create(
      name: 'Classic Burger',
      description: 'Beef patty with lettuce, tomato, and pickle',
      price: 12.99,
      category_id: burgers.id,
    )

    cheese_burger = Product.create(
      name: 'Cheeseburger',
      description: 'Classic burger with melted cheese',
      price: 14.99,
      category_id: burgers.id,
    )

    # Create pizzas
    margherita = Product.create(
      name: 'Margherita Pizza',
      description: 'Fresh mozzarella, tomato sauce, and basil',
      price: 16.99,
      category_id: pizza.id,
    )

    pepperoni = Product.create(
      name: 'Pepperoni Pizza',
      description: 'Classic pepperoni with mozzarella cheese',
      price: 18.99,
      category_id: pizza.id,
    )

    # Create desserts
    Product.create(
      name: 'Ice Cream',
      description: 'Vanilla, chocolate, or strawberry',
      price: 5.99,
      category_id: desserts.id,
    )

    Product.create(
      name: 'Cheesecake',
      description: 'New York style cheesecake with berry sauce',
      price: 7.99,
      category_id: desserts.id,
    )

    puts 'Created products'

    # Create modifier products (toppings that can't be sold separately)
    cheese = Product.create(
      name: 'Extra Cheese',
      price: 1.50,
      can_be_sold_separately: false,
    )

    bacon = Product.create(
      name: 'Bacon',
      price: 2.00,
      can_be_sold_separately: false,
    )

    mushrooms = Product.create(
      name: 'Mushrooms',
      price: 1.00,
      can_be_sold_separately: false,
    )

    onions = Product.create(
      name: 'Onions',
      price: 0.50,
      can_be_sold_separately: false,
    )

    # Create toppings for pizza
    pepperoni_topping = Product.create(
      name: 'Pepperoni',
      price: 2.50,
      can_be_sold_separately: false,
    )

    sausage = Product.create(
      name: 'Italian Sausage',
      price: 2.50,
      can_be_sold_separately: false,
    )

    puts 'Created modifier products'

    # Create modifiers for burgers
    burger_toppings = ProductModifier.create(
      name: 'Burger Toppings',
      description: 'Add extra toppings to your burger',
      product_id: classic_burger.id,
      required: false,
      min_selections: 0,
      max_selections: 5,
    )

    # Add topping options for burger
    ProductModifierOption.create(
      product_modifier_id: burger_toppings.id,
      product_id: cheese.id,
      additional_price: 1.50,
    )

    ProductModifierOption.create(
      product_modifier_id: burger_toppings.id,
      product_id: bacon.id,
      additional_price: 2.00,
    )

    ProductModifierOption.create(
      product_modifier_id: burger_toppings.id,
      product_id: mushrooms.id,
      additional_price: 1.00,
    )

    ProductModifierOption.create(
      product_modifier_id: burger_toppings.id,
      product_id: onions.id,
      additional_price: 0.50,
    )

    # Create the same modifier for cheeseburger
    cheese_burger_toppings = ProductModifier.create(
      name: 'Burger Toppings',
      description: 'Add extra toppings to your cheeseburger',
      product_id: cheese_burger.id,
      required: false,
      min_selections: 0,
      max_selections: 5,
    )

    [cheese, bacon, mushrooms, onions].each do |topping|
      ProductModifierOption.create(
        product_modifier_id: cheese_burger_toppings.id,
        product_id: topping.id,
        additional_price: topping.price,
      )
    end

    # Create pizza size modifier
    pizza_size = ProductModifier.create(
      name: 'Pizza Size',
      description: 'Choose your pizza size',
      product_id: margherita.id,
      required: true,
      min_selections: 1,
      max_selections: 1,
    )

    # Pizza sizes (using separate products)
    small_size = Product.create(
      name: 'Small (10")',
      price: 0.00,
      can_be_sold_separately: false,
    )

    medium_size = Product.create(
      name: 'Medium (12")',
      price: 3.00,
      can_be_sold_separately: false,
    )

    large_size = Product.create(
      name: 'Large (14")',
      price: 6.00,
      can_be_sold_separately: false,
    )

    ProductModifierOption.create(
      product_modifier_id: pizza_size.id,
      product_id: small_size.id,
      additional_price: 0.00,
      default_selected: true,
    )

    ProductModifierOption.create(
      product_modifier_id: pizza_size.id,
      product_id: medium_size.id,
      additional_price: 3.00,
    )

    ProductModifierOption.create(
      product_modifier_id: pizza_size.id,
      product_id: large_size.id,
      additional_price: 6.00,
    )

    # Pizza toppings
    pizza_toppings = ProductModifier.create(
      name: 'Extra Toppings',
      description: 'Add extra toppings to your pizza',
      product_id: margherita.id,
      required: false,
      min_selections: 0,
      max_selections: 8,
    )

    [pepperoni_topping, sausage, mushrooms, onions, cheese].each do |topping|
      ProductModifierOption.create(
        product_modifier_id: pizza_toppings.id,
        product_id: topping.id,
        additional_price: topping.price,
      )
    end

    # Duplicate modifiers for pepperoni pizza
    pepperoni_size = ProductModifier.create(
      name: 'Pizza Size',
      description: 'Choose your pizza size',
      product_id: pepperoni.id,
      required: true,
      min_selections: 1,
      max_selections: 1,
    )

    [small_size, medium_size, large_size].each_with_index do |size, index|
      ProductModifierOption.create(
        product_modifier_id: pepperoni_size.id,
        product_id: size.id,
        additional_price: [0.00, 3.00, 6.00][index],
        default_selected: index.zero?,
      )
    end

    pepperoni_extra_toppings = ProductModifier.create(
      name: 'Extra Toppings',
      description: 'Add extra toppings to your pizza',
      product_id: pepperoni.id,
      required: false,
      min_selections: 0,
      max_selections: 8,
    )

    [sausage, mushrooms, onions, cheese].each do |topping|
      ProductModifierOption.create(
        product_modifier_id: pepperoni_extra_toppings.id,
        product_id: topping.id,
        additional_price: topping.price,
      )
    end

    puts 'Created product modifiers and options'
    puts 'Seed data creation completed!'
    puts "\nDefault admin credentials:"
    puts 'Email: admin@restaurant.com'
    puts 'Password: admin123'
  end
end

# Run seed data creation if this file is executed directly
SeedData.create! if __FILE__ == $PROGRAM_NAME
