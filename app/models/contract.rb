class Contract < ApplicationRecord
  def name
    "#{code}-#{year}-#{order}"
  end
end
