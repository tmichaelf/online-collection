class FlashComponent < ApplicationComponent
  def initialize(flash:)
    @flash = flash
  end

  def call
    safe_join(messages.map { |type, message| tag.div(message, class: [ "flash", "flash--#{type}" ], role: "status") })
  end

  def render?
    messages.any?
  end

  private
    def messages
      @flash.to_hash.stringify_keys.slice("notice", "alert").compact_blank
    end
end
