# frozen_string_literal: true

module ProductModifierCrudRoutes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_product_modifier_crud_routes
      # Product Modifier endpoints
      get '/product-modifiers' do
        handle_database_errors do
          modifiers = ProductModifier.dataset
          modifiers = modifiers.where(product_id: params[:product_id]) if params[:product_id]

          page = (params[:page] || 1).to_i
          per_page = (params[:per_page] || 10).to_i
          offset = (page - 1) * per_page

          total = modifiers.count
          total_pages = (total.to_f / per_page).ceil

          modifiers = modifiers.limit(per_page).offset(offset)

          {
            data: modifiers.all.map do |modifier|
              modifier_hash = modifier.to_hash
              if modifier.product
                modifier_hash[:product] = {
                  id: modifier.product.id,
                  name: modifier.product.name,
                }
              end
              modifier_hash[:options_count] = ProductModifierOption.where(product_modifier_id: modifier.id).count
              modifier_hash
            end,
            pagination: {
              page: page,
              per_page: per_page,
              total: total,
              total_pages: total_pages,
            },
          }.to_json
        end
      end

      get '/product-modifiers/:id' do
        modifier = ProductModifier[params[:id]]
        halt 404, { error: 'Product modifier not found' }.to_json unless modifier

        modifier_hash = modifier.to_hash
        if modifier.product
          modifier_hash[:product] = {
            id: modifier.product.id,
            name: modifier.product.name,
            category: modifier.product.category&.name,
          }
        end

        modifier_hash[:options] = ProductModifierOption.where(product_modifier_id: modifier.id).map do |option|
          {
            id: option.id,
            product: {
              id: option.product.id,
              name: option.product.name,
              price: format('%.2f', option.product.price),
            },
            additional_price: format('%.2f', option.additional_price),
            default_selected: option.default_selected || false,
          }
        end

        modifier_hash.to_json
      end

      post '/product-modifiers' do
        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_database_errors do
            required_fields = [:name, :product_id, :min_selections, :max_selections]
            missing_fields = required_fields.select { |field| data[field].nil? }

            unless missing_fields.empty?
              status 422
              return { error: "Missing required fields: #{missing_fields.join(', ')}" }.to_json
            end

            product = Product[data[:product_id]]
            unless product
              status 422
              return { error: 'Product not found' }.to_json
            end

            if data[:min_selections].negative? || data[:max_selections] < data[:min_selections]
              status 422
              return { error: 'Invalid selection constraints' }.to_json
            end

            modifier = ProductModifier.create(data)
            status 201

            modifier_hash = modifier.to_hash
            modifier_hash[:product] = {
              id: product.id,
              name: product.name,
            }
            modifier_hash[:options] = []

            modifier_hash.to_json
          end
        end
      end

      put '/product-modifiers/:id' do
        modifier = ProductModifier[params[:id]]
        halt 404, { error: 'Product modifier not found' }.to_json unless modifier

        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_database_errors do
            if data[:product_id] && data[:product_id] != modifier.product_id
              product = Product[data[:product_id]]
              unless product
                status 422
                return { error: 'Product not found' }.to_json
              end
            end

            min_sel = data[:min_selections] || modifier.min_selections
            max_sel = data[:max_selections] || modifier.max_selections

            if min_sel.negative? || max_sel < min_sel
              status 422
              return { error: 'Invalid selection constraints' }.to_json
            end

            modifier.update(data)

            modifier_hash = modifier.to_hash
            if modifier.product
              modifier_hash[:product] = {
                id: modifier.product.id,
                name: modifier.product.name,
              }
            end

            modifier_hash.to_json
          end
        end
      end

      delete '/product-modifiers/:id' do
        modifier = ProductModifier[params[:id]]
        halt 404, { error: 'Product modifier not found' }.to_json unless modifier

        handle_database_errors do
          ProductModifierOption.where(product_modifier_id: modifier.id).delete

          modifier.destroy
          { message: 'Product modifier deleted successfully' }.to_json
        end
      end
    end
  end
end
