# frozen_string_literal: true

module CategoryRoutes
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def register_category_routes
      # Category endpoints
      get '/categories' do
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 2).to_i

        total = Category.count
        total_pages = (total.to_f / per_page).ceil

        offset = (page - 1) * per_page
        categories = Category.limit(per_page).offset(offset).all

        {
          data: categories.map(&:to_hash),
          pagination: {
            page: page,
            per_page: per_page,
            total: total,
            total_pages: total_pages,
          },
        }.to_json
      end

      get '/categories/tree' do
        root_categories = Category.where(parent_id: nil).order(:sort_order).all
        tree_data = root_categories.map do |category|
          category_hash = category.to_hash
          category_hash[:subcategories] = Category.where(parent_id: category.id).order(:sort_order).map(&:to_hash)
          category_hash
        end
        tree_data.to_json
      end

      post '/categories' do
        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_database_errors do
            category = Category.create(data)
            status 201
            category.to_hash.to_json
          end
        end
      end

      put '/categories/:id' do
        category = Category[params[:id]]
        halt 404, { error: 'Category not found' }.to_json unless category

        handle_json_parse_error do
          data = JSON.parse(request.body.read, symbolize_names: true)

          handle_database_errors do
            category.update(data)
            category.to_hash.to_json
          end
        end
      end

      delete '/categories/:id' do
        category = Category[params[:id]]
        halt 404, { error: 'Category not found' }.to_json unless category

        handle_database_errors do
          if Product.where(category_id: category.id).any?
            status 422
            return { error: 'Cannot delete category with products' }.to_json
          end

          category.destroy
          { message: 'Category deleted successfully' }.to_json
        end
      end
    end
  end
end
