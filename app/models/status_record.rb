class StatusRecord < NamedRecord
  self.abstract_class = true
  # аудит изменений
  include Auditable

  # реализация для набора данных :item
  def item
    super.merge({ description: description })
  end

  # реализация для набора данных card
  def card
    super.merge({ description: description, order: order })
  end

  def self.permitted_params
    super | [:description, :order]
  end
end
