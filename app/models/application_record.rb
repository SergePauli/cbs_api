class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def data_sets
    [:head, :item, :card, :summary, :full]
  end

  def custom_data(data_set)
    if data_sets.include?(data_set)
      method = method(data_set)
      return method.call if method
    end
    false
  end

  def head
    name || to_s
  end

  def item
    { id: id, name: head }
  end

  def summary
    { created: created_at || nil, updated: updated_at || nil }
  end

  def card
    { head: head, id: id, summary: { created: created_at || nil, updated: updated_at || nil } }
  end
end
