class CollectionItemsController < ApplicationController
  before_action :set_collection_item, only: %i[ update destroy ]

  def create
    @collection_item = Current.user.collection_items.new(collection_item_params)

    if @collection_item.save
      redirect_to @collection_item.title, notice: "Added to your collection."
    else
      redirect_to title_path(collection_item_params[:title_id]), alert: @collection_item.errors.full_messages.to_sentence
    end
  end

  def update
    if @collection_item.update(collection_item_params.except(:title_id))
      redirect_to @collection_item.title, notice: "Collection updated."
    else
      redirect_to @collection_item.title, alert: @collection_item.errors.full_messages.to_sentence
    end
  end

  def destroy
    @collection_item.destroy
    redirect_to @collection_item.title, notice: "Removed from your collection.", status: :see_other
  end

  private
    def set_collection_item
      @collection_item = Current.user.collection_items.find(params.expect(:id))
    end

    def collection_item_params
      params.expect(collection_item: %i[ title_id condition notes acquired_on ])
    end
end
