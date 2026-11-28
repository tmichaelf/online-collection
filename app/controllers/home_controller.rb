class HomeController < ApplicationController
  allow_unauthenticated_access

  def show
    @demo_collector = User.demo
    @collection_items = @demo_collector ? @demo_collector.collection_items.includes(title: { front_image_attachment: :blob }).by_title_name.limit(12) : CollectionItem.none
  end
end
