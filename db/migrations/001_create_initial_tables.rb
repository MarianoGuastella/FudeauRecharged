# frozen_string_literal: true

require_relative '../../config/database'

Sequel.migration do
  up do
    # Users table for authentication
    create_table :users do
      primary_key :id
      String :email, null: false, unique: true
      String :password_hash, null: false
      String :name, null: false
      Boolean :active, default: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # Categories table (self-referential for subcategories)
    create_table :categories do
      primary_key :id
      String :name, null: false
      String :description
      Integer :parent_id, foreign_key: { table: :categories, on_delete: :cascade }
      Integer :sort_order, default: 0
      Boolean :active, default: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      
      index :parent_id
      index :sort_order
    end

    # Products table
    create_table :products do
      primary_key :id
      String :name, null: false
      String :description
      Decimal :price, size: [10, 2], null: false
      Integer :category_id, foreign_key: { table: :categories, on_delete: :set_null }
      Boolean :available, default: true
      Boolean :can_be_sold_separately, default: true
      String :image_url
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      
      index :category_id
      index :available
    end

    # Product modifiers table
    create_table :product_modifiers do
      primary_key :id
      String :name, null: false
      String :description
      Integer :product_id, foreign_key: { table: :products, on_delete: :cascade }
      Boolean :required, default: false
      Integer :min_selections, default: 0
      Integer :max_selections, default: 1
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      
      index :product_id
    end

    # Product modifier options (products that can be selected as modifiers)
    create_table :product_modifier_options do
      primary_key :id
      Integer :product_modifier_id, foreign_key: { table: :product_modifiers, on_delete: :cascade }
      Integer :product_id, foreign_key: { table: :products, on_delete: :cascade }
      Decimal :additional_price, size: [10, 2], default: 0.0
      Boolean :default_selected, default: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      
      index [:product_modifier_id, :product_id], unique: true
    end
  end

  down do
    drop_table :product_modifier_options
    drop_table :product_modifiers
    drop_table :products
    drop_table :categories
    drop_table :users
  end
end