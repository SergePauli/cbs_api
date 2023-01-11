# хранение реквизитов контрагентов - юр.лиц
# контрагент может менять регистрацию - потому используем MutableData
class ContragentOrganization < MutableData
  belongs_to :contragent, inverse_of: :contragent_organization
  belongs_to :organization
  validates_associated :contragent
  validates_associated :organization
  validates :contragent, uniqueness: { scope: :organization }
  alias_attribute :state, :organization # для поддержки MutableData
  accepts_nested_attributes_for :organization

  def self.permitted_params
    super | [:contragent_id, :organization_id, organization_attributes: Organization.permitted_params]
  end
end
