# frozen_string_literal: true

require_relative 'product_modifier_crud_routes'
require_relative 'product_modifier_option_routes'

module ProductModifierRoutes
  def self.included(base)
    base.include(ProductModifierCrudRoutes)
    base.include(ProductModifierOptionRoutes)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_product_modifier_routes
      register_product_modifier_crud_routes
      register_product_modifier_option_routes
    end
  end
end
