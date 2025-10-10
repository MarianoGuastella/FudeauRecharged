# frozen_string_literal: true

require 'sequel'
require_relative '../../config/database'

class Category < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :json_serializer
  plugin :validation_helpers

  many_to_one :parent, class: self, key: :parent_id
  one_to_many :subcategories, class: self, key: :parent_id
  one_to_many :products

  def validate
    super
    validates_presence [:name]
    validates_type Integer, :sort_order
  end

  def to_hash_with_associations
    hash = to_hash
    hash[:subcategories] = subcategories.map(&:to_hash) if subcategories.any?
    hash
  end

  def self.root_categories
    where(parent_id: nil).order(:sort_order, :name)
  end

  def self.build_tree
    root_categories.map(&:to_hash_with_associations)
  end

  def self.by_id(id)
    where(id: id).first
  end
end
