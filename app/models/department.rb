class Department < NamedRecord
  validates :def_statuses, format: { with: /\A\d,(\d,)+\d/, message: "invalid array of statuses" }
  validates :def_contracts_types, format: { with: /\A\d{1,2},(\d{1,2},)+\d{1,2}/, message: "invalid array of types" }

  def self.permitted_params
    super | [:def_statuses, :def_contracts_types]
  end
end
