class Contract < ApplicationRecord
  # используется режим сроков
  include Deadlineable

  has_many :contract_numbers

  def name
    "#{code}-#{year}-#{order.to_s.ljust(2, "0")}"
  end
end
