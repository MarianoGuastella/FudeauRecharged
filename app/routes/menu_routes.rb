# frozen_string_literal: true

module MenuRoutes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_menu_routes
      # Menu endpoints
      get '/menus' do
        categories = Category
                     .where(parent_id: nil)
                     .eager(
                       subcategories: {
                         products: {
                           product_modifiers: {
                             product_modifier_options: :product,
                           },
                         },
                       },
                     )
                     .order(:sort_order)
                     .all

        menu_data = {
          menu: {
            categories: categories.map do |category|
              {
                id: category.id,
                name: category.name,
                description: category.description,
                subcategories: category.subcategories.map do |subcategory|
                  {
                    id: subcategory.id,
                    name: subcategory.name,
                    description: subcategory.description,
                    products: subcategory.products.map do |product|
                      product_hash = product.to_hash
                      product_hash[:modifiers] = product.product_modifiers.map do |modifier|
                        {
                          id: modifier.id,
                          name: modifier.name,
                          description: modifier.description,
                          required: modifier.required,
                          min_selections: modifier.min_selections,
                          max_selections: modifier.max_selections,
                          options: modifier.product_modifier_options.map do |option|
                            {
                              id: option.id,
                              product: {
                                id: option.product.id,
                                name: option.product.name,
                                description: option.product.description,
                                price: format('%.1f', option.product.price).sub(/\.0$/, ''),
                              },
                              additional_price: format('%.1f', option.additional_price).sub(/\.0$/, ''),
                              default_selected: option.default_selected || false,
                            }
                          end,
                        }
                      end
                      product_hash
                    end,
                  }
                end,
              }
            end,
          },
        }
        menu_data.to_json
      end

      get '/menus/categories/:id' do
        category = Category[params[:id]]
        halt 404, { error: 'Category not found' }.to_json unless category

        products = Product
                   .where(category_id: category.id)
                   .eager(
                     product_modifiers: {
                       product_modifier_options: :product,
                     },
                   )
                   .all

        menu_data = {
          id: category.id,
          name: category.name,
          description: category.description,
          products: products.map do |product|
            product_hash = product.to_hash
            product_hash[:modifiers] = product.product_modifiers.map do |modifier|
              {
                id: modifier.id,
                name: modifier.name,
                description: modifier.description,
                required: modifier.required,
                min_selections: modifier.min_selections,
                max_selections: modifier.max_selections,
                options: modifier.product_modifier_options.map do |option|
                  {
                    id: option.id,
                    product: {
                      id: option.product.id,
                      name: option.product.name,
                      description: option.product.description,
                      price: format('%.1f', option.product.price).sub(/\.0$/, ''),
                    },
                    additional_price: format('%.1f', option.additional_price).sub(/\.0$/, ''),
                    default_selected: option.default_selected || false,
                  }
                end,
              }
            end
            product_hash
          end,
        }
        menu_data.to_json
      end
    end
  end
end
