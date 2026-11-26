class TitlesController < ApplicationController
  allow_unauthenticated_access

  def index
    @titles = Title.alphabetical
  end

  def show
    @title = Title.find(params.expect(:id))
    @collection_item = Current.user.collection_items.find_by(title: @title) if authenticated?
  end
end
