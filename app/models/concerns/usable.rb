module Usable
  extend ActiveSupport::Concern

  included do
    def used_items(list)
      list.filter { |el| el.used }.map { |el| el.item } || []
    end
  end
end
