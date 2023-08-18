class IsecurityTool < NamedRecord
  # аудит изменений
  include Auditable

  # реализация для набора данных :item
  def item
    super.merge({ unit: unit })
  end

  # реализация для набора данных card
  def card
    super.merge({ unit: unit, priority: priority, used: used })
  end

  # реализация для набора данных edit
  def edit
    super.merge({ name: name, unit: unit, priority: priority, used: used })
  end

  def self.permitted_params
    super | [:unit, :priority, :used]
  end
end
