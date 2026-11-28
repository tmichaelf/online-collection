class PaginationComponent < ApplicationComponent
  def initialize(pagination:, params:)
    @pagination = pagination
    @params = params
  end

  def render?
    @pagination.total_pages > 1
  end

  private
    attr_reader :pagination

    def page_path(number)
      helpers.url_for(@params.to_h.merge(page: number, only_path: true))
    end
end
