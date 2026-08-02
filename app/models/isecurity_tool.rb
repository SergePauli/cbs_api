class IsecurityTool < NamedRecord  

  # реализация для набора данных :item
  def item
    super.merge({ unit: unit })
  end

  # реализация для набора данных card
  def card
    super.merge({ name: name, unit: unit, kind: kind, default_cost: default_cost }) 
  end

  # реализация для набора данных edit
  def edit
    super.merge({ name: name, unit: unit, kind: kind, default_cost: default_cost })
  end

  def self.permitted_params
    super | [:unit, :kind, :default_cost]
  end
end
