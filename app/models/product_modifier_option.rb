# frozen_string_literal: true

require 'sequel'
require_relative '../../config/database'

class ProductModifierOption < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :json_serializer
  plugin :validation_helpers

  many_to_one :product_modifier
  many_to_one :product

  def validate
    super
    validates_presence [:product_modifier_id, :product_id]
    validates_type Numeric, :additional_price
    validates_operator(:>=, 0, :additional_price)
  end

  def to_hash_with_associations
    hash = to_hash
    hash[:product] = product.to_hash if product
    hash
  end

  def self.by_id(id)
    where(id: id).first
  end
end