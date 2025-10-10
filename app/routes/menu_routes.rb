# frozen_string_literal: true

module MenuRoutes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_menu_routes
      # Menu endpoints
      get '/menus' do
        categories = Category.where(parent_id: nil).all
        menu_data = {
          menu: {
            categories: categories.map do |category|
              {
                id: category.id,
                name: category.name,
                description: category.description,
                subcategories: Category.where(parent_id: category.id).map do |subcategory|
                  {
                    id: subcategory.id,
                    name: subcategory.name,
                    description: subcategory.description,
                    products: Product.where(category_id: subcategory.id).map do |product|
                      product_hash = product.to_hash
                      product_hash[:modifiers] = ProductModifier.where(product_id: product.id).map do |modifier|
                        {
                          id: modifier.id,
                          name: modifier.name,
                          description: modifier.description,
                          required: modifier.required,
                          min_selections: modifier.min_selections,
                          max_selections: modifier.max_selections,
                          options: ProductModifierOption.where(product_modifier_id: modifier.id).map do |option|
                            {
                              id: option.id,
                              product: {
                                id: option.product.id,
                                name: option.product.name,
                                description: option.product.description,
                                price: sprintf('%.1f', option.product.price).sub(/\.0$/, '')
                              },
                              additional_price: sprintf('%.1f', option.additional_price).sub(/\.0$/, ''),
                              default_selected: option.default_selected || false
                            }
                          end
                        }
                      end
                      product_hash
                    end
                  }
                end
              }
            end
          }
        }
        menu_data.to_json
      end

      get '/menus/categories/:id' do
        category = Category[params[:id]]
        halt 404, { error: 'Category not found' }.to_json unless category
        
        menu_data = {
          id: category.id,
          name: category.name,
          description: category.description,
          products: Product.where(category_id: category.id).map do |product|
            product_hash = product.to_hash
            product_hash[:modifiers] = ProductModifier.where(product_id: product.id).map do |modifier|
              {
                id: modifier.id,
                name: modifier.name,
                description: modifier.description,
                required: modifier.required,
                min_selections: modifier.min_selections,
                max_selections: modifier.max_selections,
                options: ProductModifierOption.where(product_modifier_id: modifier.id).map do |option|
                  {
                    id: option.id,
                    product: {
                      id: option.product.id,
                      name: option.product.name,
                      description: option.product.description,
                      price: sprintf('%.1f', option.product.price).sub(/\.0$/, '')
                    },
                    additional_price: sprintf('%.1f', option.additional_price).sub(/\.0$/, ''),
                    default_selected: option.default_selected || false
                  }
                end
              }
            end
            product_hash
          end
        }
        menu_data.to_json
      end
    end
  end
end