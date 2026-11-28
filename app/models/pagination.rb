# Splits a relation into numbered pages.
class Pagination
  PER_PAGE = 24

  attr_reader :number, :per_page

  def initialize(scope, page: 1, per_page: PER_PAGE)
    @scope = scope
    @per_page = per_page
    @number = [ page.to_i, 1 ].max
  end

  def records
    @scope.limit(per_page).offset((number - 1) * per_page)
  end

  def total_count
    @total_count ||= @scope.unscope(:order).count
  end

  def total_pages
    [ (total_count / per_page.to_f).ceil, 1 ].max
  end

  def first?
    number == 1
  end

  def last?
    number >= total_pages
  end

  def next_number
    number + 1 unless last?
  end

  def previous_number
    number - 1 unless first?
  end
end
