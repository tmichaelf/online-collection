class CollectorsController < ApplicationController
  allow_unauthenticated_access

  def index
    @collectors = User.order(:username)
  end

  def show
    @collector = User.find_by!(username: params.expect(:username))
    @collection_items = @collector.collection_items.includes(:title).by_title_name
  end
end
