class TaskKind < NamedRecord
  def card
    super.merge({ description: description, cost: cost, duration: duration })
  end

  def self.permitted_params
    super | [:description, :cost, :duration]
  end
end
