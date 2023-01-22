# хранение реквизитов контрагентов - юр.лиц
# контрагент может менять регистрацию - потому используем MutableData
class ContragentOrganization < MutableData
  belongs_to :contragent, inverse_of: :contragent_organization
  belongs_to :organization
  validates_associated :contragent
  validates_associated :organization
  validates :contragent, uniqueness: { scope: :organization }
  validates :organization, uniqueness: { scope: :used }
  alias_attribute :state, :organization # для поддержки MutableData
  accepts_nested_attributes_for :organization

  def item
    super.merge({ organization: organization.item })
  end

  def card
    super.merge({ organization: organization.card })
  end

  def self.permitted_params
    super | [:contragent_id, :organization_id, organization_attributes: Organization.permitted_params]
  end
end
