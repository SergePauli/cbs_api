class ContractResponsible < MutableData
  belongs_to :contract, inverse_of: :contract_responsibles
  belongs_to :employee

  validates :employee_id, uniqueness: { scope: :contract_id }
  validate :employee_belongs_to_contract_contragent

  alias_attribute :state, :employee
  alias_attribute :main_model, :contract

  def name
    employee.name
  end

  def edit
    super.merge({ employee_id: employee_id, employee: employee.item })
  end

  def card
    super.merge({ contract: contract.item, employee: employee.item })
  end

  def self.permitted_params
    super | [:contract_id, :employee_id]
  end

  private

  def employee_belongs_to_contract_contragent
    return if contract.blank? || employee.blank?
    return if employee.contragent_id == contract.contragent_id

    errors.add(:employee, "должен принадлежать контрагенту контракта")
  end
end
