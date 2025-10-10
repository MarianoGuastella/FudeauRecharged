# frozen_string_literal: true

require 'sequel'
require_relative '../../config/database'

class Product < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :json_serializer
  plugin :validation_helpers

  many_to_one :category
  one_to_many :product_modifiers
  one_to_many :product_modifier_options

  def validate
    super
    validates_presence [:name, :price]
    validates_type Numeric, :price
    validates_operator(:>=, 0, :price)
  end

  def to_hash_with_associations
    hash = to_hash
    hash[:category] = category.to_hash if category
    hash
  end

  def to_hash
    hash = super
    hash[:price] = format_price(price) if price
    hash
  end

  private

  def format_price(price)
    formatted = sprintf('%.2f', price)
    formatted.sub(/\.00$/, '').sub(/\.(\d)0$/, '.\\1')
  end

  def self.available
    where(available: true)
  end

  def self.by_category(category_id)
    where(category_id: category_id)
  end

  def self.by_id(id)
    where(id: id).first
  end
end