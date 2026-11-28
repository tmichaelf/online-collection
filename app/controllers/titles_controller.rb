class TitlesController < ApplicationController
  allow_unauthenticated_access

  def index
    @filters = filter_params
    @filter_options = Title.filter_options
    @pagination = Pagination.new(Title.search(**search_arguments), page: params[:page])
    @titles = @pagination.records.with_attached_front_image
  end

  def show
    @title = Title.with_attached_faces.find(params.expect(:id))
    @collection_item = Current.user.collection_items.find_by(title: @title) if authenticated?
  end

  private
    def filter_params
      params.permit(:q, :publisher, :genre, :platform, :decade, :sort).compact_blank.to_h
    end

    def search_arguments
      @filters.symbolize_keys.transform_keys { |key| key == :q ? :query : key }
    end
end
