# frozen_string_literal: true

module PaginationHelpers
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  def pagination_params
    page = (params[:page] || DEFAULT_PAGE).to_i
    per_page = (params[:per_page] || DEFAULT_PER_PAGE).to_i

    page = 1 if page < 1
    per_page = DEFAULT_PER_PAGE if per_page < 1
    per_page = MAX_PER_PAGE if per_page > MAX_PER_PAGE

    {
      page: page,
      per_page: per_page,
      offset: (page - 1) * per_page,
    }
  end

  def pagination_metadata(total:, page:, per_page:)
    total_pages = (total.to_f / per_page).ceil

    {
      page: page,
      per_page: per_page,
      total: total,
      total_pages: total_pages,
      has_next_page: page < total_pages,
      has_prev_page: page > 1,
    }
  end

  def paginate_dataset(dataset)
    params = pagination_params
    total = dataset.count

    paginated = dataset.limit(params[:per_page]).offset(params[:offset])

    {
      data: paginated,
      pagination: pagination_metadata(
        total: total,
        page: params[:page],
        per_page: params[:per_page],
      ),
    }
  end
end
