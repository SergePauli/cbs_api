class Contract < ApplicationRecord
  # используется режим сроков
  include Deadlineable

  def name
    "#{code}-#{year}-#{order.to_s.ljust(2, "0")}"
  end
end
