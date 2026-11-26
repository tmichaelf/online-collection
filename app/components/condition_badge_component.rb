class ConditionBadgeComponent < ApplicationComponent
  LABELS = {
    "sealed" => "Sealed",
    "complete" => "Complete in box",
    "incomplete" => "Incomplete",
    "box_only" => "Box only"
  }.freeze

  def initialize(condition:)
    @condition = condition.to_s
  end

  def call
    tag.span LABELS.fetch(@condition, @condition.humanize), class: [ "badge", "badge--#{@condition.dasherize}" ]
  end

  def self.options
    LABELS.map { |value, label| [ label, value ] }
  end
end
