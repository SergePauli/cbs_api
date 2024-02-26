class Ownership < NamedRecord
  def item
    super.merge({ okopf: okopf })
  end

  def card
    super.merge({ full_name: full_name, okopf: okopf })
  end

  def self.permitted_params
    super | [:full_name, :okopf]
  end
end
