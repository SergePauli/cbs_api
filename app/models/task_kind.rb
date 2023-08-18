class TaskKind < NamedRecord
  # аудит изменений
  include Auditable

  validates :code, format: { with: /[0-9]{2}/,
                             message: "Указан неверный код типа контракта" }, allow_nil: true

  def item
    code.blank? ? super : super.merge({ code: code })
  end

  def card
    super.merge({ code: code, description: description, cost: cost, duration: duration })
  end

  def self.permitted_params
    super | [:description, :cost, :duration, :code]
  end
end
