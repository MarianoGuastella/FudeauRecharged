# frozen_string_literal: true

module ProductModifierOptionRoutes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_product_modifier_option_routes
      # Product Modifier Options endpoints
      get '/product-modifiers/:modifier_id/options' do
        modifier = ProductModifier[params[:modifier_id]]
        halt 404, { error: 'Product modifier not found' }.to_json unless modifier

        options = ProductModifierOption.where(product_modifier_id: modifier.id).all

        {
          data: options.map do |option|
            {
              id: option.id,
              product: {
                id: option.product.id,
                name: option.product.name,
                price: format('%.2f', option.product.price),
                can_be_sold_separately: option.product.can_be_sold_separately,
              },
              additional_price: format('%.2f', option.additional_price),
              default_selected: option.default_selected || false,
            }
          end,
        }.to_json
      end

      post '/product-modifiers/:modifier_id/options' do
        modifier = ProductModifier[params[:modifier_id]]
        halt 404, { error: 'Product modifier not found' }.to_json unless modifier

        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_database_errors do
            # Validate required fields
            unless data[:product_id]
              status 422
              return { error: 'Missing required field: product_id' }.to_json
            end

            # Validate product exists
            product = Product[data[:product_id]]
            unless product
              status 422
              return { error: 'Product not found' }.to_json
            end

            existing_option = ProductModifierOption.where(
              product_modifier_id: modifier.id,
              product_id: data[:product_id],
            ).first

            if existing_option
              status 422
              return { error: 'Option for this product already exists in this modifier' }.to_json
            end

            data[:product_modifier_id] = modifier.id
            data[:additional_price] ||= 0.0
            data[:default_selected] ||= false

            option = ProductModifierOption.create(data)
            status 201

            {
              id: option.id,
              product: {
                id: product.id,
                name: product.name,
                price: format('%.2f', product.price),
              },
              additional_price: format('%.2f', option.additional_price),
              default_selected: option.default_selected,
            }.to_json
          end
        end
      end

      put '/product-modifiers/:modifier_id/options/:option_id' do
        modifier = ProductModifier[params[:modifier_id]]
        halt 404, { error: 'Product modifier not found' }.to_json unless modifier

        option = ProductModifierOption[params[:option_id]]
        halt 404, { error: 'Modifier option not found' }.to_json unless option

        unless option.product_modifier_id == modifier.id
          halt 422, { error: 'Option does not belong to this modifier' }.to_json
        end

        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_database_errors do
            # Validate product exists if changing product_id
            if data[:product_id] && data[:product_id] != option.product_id
              product = Product[data[:product_id]]
              unless product
                status 422
                return { error: 'Product not found' }.to_json
              end

              # Check if option already exists for new product
              existing_option = ProductModifierOption.where(
                product_modifier_id: modifier.id,
                product_id: data[:product_id],
              ).exclude(id: option.id).first

              if existing_option
                status 422
                return { error: 'Option for this product already exists in this modifier' }.to_json
              end
            end

            option.update(data)

            {
              id: option.id,
              product: {
                id: option.product.id,
                name: option.product.name,
                price: format('%.2f', option.product.price),
              },
              additional_price: format('%.2f', option.additional_price),
              default_selected: option.default_selected,
            }.to_json
          end
        end
      end

      delete '/product-modifiers/:modifier_id/options/:option_id' do
        modifier = ProductModifier[params[:modifier_id]]
        halt 404, { error: 'Product modifier not found' }.to_json unless modifier

        option = ProductModifierOption[params[:option_id]]
        halt 404, { error: 'Modifier option not found' }.to_json unless option

        # Verify option belongs to modifier
        unless option.product_modifier_id == modifier.id
          halt 422, { error: 'Option does not belong to this modifier' }.to_json
        end

        handle_database_errors do
          option.destroy
          { message: 'Modifier option deleted successfully' }.to_json
        end
      end
    end
  end
end
