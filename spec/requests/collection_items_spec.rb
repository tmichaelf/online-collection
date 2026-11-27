require "rails_helper"

RSpec.describe "Collection items", type: :request do
  let(:user) { create(:user) }
  let(:title) { create(:title) }

  it "requires signing in" do
    post collection_items_path, params: { collection_item: { title_id: title.id } }
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as user }

    it "adds a title to the collection" do
      expect {
        post collection_items_path, params: { collection_item: { title_id: title.id, condition: "sealed" } }
      }.to change { user.collection_items.count }.by(1)
      expect(user.collection_items.last).to be_sealed
    end

    it "updates the condition" do
      item = create(:collection_item, user: user, title: title)
      patch collection_item_path(item), params: { collection_item: { condition: "box_only" } }
      expect(item.reload).to be_box_only
    end

    it "removes a title" do
      item = create(:collection_item, user: user, title: title)
      expect { delete collection_item_path(item) }.to change(CollectionItem, :count).by(-1)
    end

    it "can't change someone else's collection" do
      other_item = create(:collection_item)
      delete collection_item_path(other_item)
      expect(response).to have_http_status(:not_found)
      expect(CollectionItem.exists?(other_item.id)).to be(true)
    end
  end
end
