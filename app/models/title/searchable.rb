# Full-text search, filters and sorting for the public archive.
module Title::Searchable
  extend ActiveSupport::Concern

  SORTS = {
    "name" => "Name",
    "newest" => "Newest release",
    "oldest" => "Oldest release",
    "recent" => "Recently added"
  }.freeze

  included do
    # Matches every word in the query, treating each as a prefix ("ultim vii" finds "Ultima VII").
    scope :matching, ->(query) {
      terms = query.to_s.downcase.scan(/[[:alnum:]]+/).first(10)
      next all if terms.empty?

      tsquery = sanitize_sql_array([ "to_tsquery('simple', ?)", terms.map { |term| "#{term}:*" }.join(" & ") ])
      where("titles.searchable @@ #{tsquery}").reorder(Arel.sql("ts_rank(titles.searchable, #{tsquery}) DESC, titles.name"))
    }

    scope :published_by, ->(publisher) { publisher.present? ? where(publisher: publisher) : all }
    scope :in_genre, ->(genre) { genre.present? ? where(genre: genre) : all }
    scope :on_platform, ->(platform) { platform.present? ? where(platform: platform) : all }
    scope :released_in_decade, ->(decade) {
      decade.to_s.match?(/\A\d{4}\z/) ? where(release_year: decade.to_i...(decade.to_i + 10)) : all
    }

    scope :sorted_by, ->(sort) {
      case sort
      when "newest" then reorder(release_year: :desc, name: :asc)
      when "oldest" then reorder(release_year: :asc, name: :asc)
      when "recent" then reorder(created_at: :desc)
      when "name" then reorder(:name)
      else all
      end
    }
  end

  class_methods do
    def search(query: nil, publisher: nil, genre: nil, platform: nil, decade: nil, sort: nil)
      titles = alphabetical
        .matching(query)
        .published_by(publisher)
        .in_genre(genre)
        .on_platform(platform)
        .released_in_decade(decade)

      sort.present? || query.blank? ? titles.sorted_by(sort.presence || "name") : titles
    end

    def filter_options
      {
        publishers: distinct_values(:publisher),
        genres: distinct_values(:genre),
        platforms: distinct_values(:platform),
        decades: where.not(release_year: nil).distinct.pluck(Arel.sql("(release_year / 10) * 10")).sort
      }
    end

    private
      def distinct_values(column)
        where.not(column => [ nil, "" ]).distinct.order(column).pluck(column)
      end
  end
end
