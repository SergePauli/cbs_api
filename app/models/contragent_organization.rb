# хранение реквизитов контрагентов - юр.лиц
# контрагент может менять регистрацию - потому используем MutableData
class ContragentOrganization < MutableData
  # только одна запись может быть используемой
  include Singleable

  belongs_to :contragent, inverse_of: :contragent_organization

  belongs_to :organization
  accepts_nested_attributes_for :organization

  validates_associated :contragent
  validates_associated :organization
  validates :contragent, uniqueness: { scope: :organization }

  alias_attribute :state, :organization # для поддержки MutableData
  alias_attribute :main_model_id, :contragent_id # для поддержки singleable

  def name
    organization.head
  end

  def item
    super.merge({ organization: organization.item })
  end

  def card
    super.merge({ organization: organization.card })
  end

  def self.permitted_params
    super | [:contragent_id, :organization_id] | [organization_attributes: Organization.permitted_params]
  end
end
