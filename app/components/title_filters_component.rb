class TitleFiltersComponent < ApplicationComponent
  def initialize(filters:, options:)
    @filters = filters
    @options = options
  end

  private
    attr_reader :filters, :options

    def decade_options
      options[:decades].map { |decade| [ "#{decade}s", decade ] }
    end

    def sort_options
      Title::SORTS.invert.to_a
    end
end
