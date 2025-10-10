# frozen_string_literal: true

require 'sequel'
require_relative '../../config/database'

class ProductModifier < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :json_serializer
  plugin :validation_helpers

  many_to_one :product
  one_to_many :product_modifier_options

  def validate
    super
    validates_presence [:name, :product_id]
    validates_type Integer, [:min_selections, :max_selections]
    validates_operator(:>=, 0, :min_selections)
    
    # Only validate max >= min if both values are present
    if min_selections && max_selections
      validates_operator(:>=, min_selections, :max_selections)
    end
  end

  def to_hash_with_associations
    hash = to_hash
    hash[:options] = product_modifier_options.map(&:to_hash_with_associations) if product_modifier_options.any?
    hash
  end

  def self.by_id(id)
    where(id: id).first
  end
end