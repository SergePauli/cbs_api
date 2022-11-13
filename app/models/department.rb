class Department < NamedRecord
  validates :def_statuses, format: { with: /\A\d,(\d,)+\d/, message: "invalid array of statuses" }
  validates :def_contract_types, format: { with: /\A\d{1,2},(\d{1,2},)+\d{1,2}/, message: "invalid array of types" }
end
