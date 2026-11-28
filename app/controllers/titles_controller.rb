class TitlesController < ApplicationController
  allow_unauthenticated_access

  def index
    @titles = Title.alphabetical.with_attached_front_image
  end

  def show
    @title = Title.with_attached_faces.find(params.expect(:id))
    @collection_item = Current.user.collection_items.find_by(title: @title) if authenticated?
  end
end
