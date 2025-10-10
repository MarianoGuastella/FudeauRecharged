# frozen_string_literal: true

module ProductRoutes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_product_routes
      # Product endpoints
      get '/products' do
        handle_database_errors do
          products = Product.dataset

          if params[:available]
            available = params[:available] == 'true'
            products = products.where(available: available)
          end

          products = products.where(category_id: params[:category_id]) if params[:category_id]

          page = (params[:page] || 1).to_i
          per_page = (params[:per_page] || 2).to_i
          offset = (page - 1) * per_page

          products = products.limit(per_page).offset(offset)

          { data: products.all.map(&:to_hash) }.to_json
        end
      end

      get '/products/:id' do
        product = Product[params[:id]]
        halt 404, { error: 'Product not found' }.to_json unless product

        response = product.to_hash
        if product.category
          response[:category] = {
            id: product.category.id,
            name: product.category.name,
          }
        end

        response.to_json
      end

      post '/products' do
        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_database_errors do
            product = Product.create(data)
            status 201
            product.to_hash.to_json
          end
        end
      end

      put '/products/:id' do
        product = Product[params[:id]]
        halt 404, { error: 'Product not found' }.to_json unless product

        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_database_errors do
            product.update(data)
            product.to_hash.to_json
          end
        end
      end

      delete '/products/:id' do
        product = Product[params[:id]]
        halt 404, { error: 'Product not found' }.to_json unless product

        handle_database_errors do
          if ProductModifier.where(product_id: product.id).any?
            status 422
            return { error: 'Cannot delete product with associated modifiers' }.to_json
          end

          if ProductModifierOption.where(product_id: product.id).any?
            status 422
            return { error: 'Cannot delete product that is used as a modifier option' }.to_json
          end

          product.destroy
          { message: 'Product deleted successfully' }.to_json
        end
      end
    end
  end
end
