class TitleCardComponent < ApplicationComponent
  with_collection_parameter :title

  def initialize(title:, condition: nil)
    @title = title
    @condition = condition
  end

  private
    attr_reader :title, :condition

    def byline
      [ title.publisher, title.release_year ].compact_blank.join(" · ")
    end
end
