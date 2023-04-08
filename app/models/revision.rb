# Номер контракта и ссылки на документы
class Revision < MutableData

  # аудит изменений
  include Auditable

  belongs_to :contract
  validates_associated :contract

  validates :contract, uniqueness: { scope: :priority }
  validates :priority, uniqueness: { scope: [:contract], message: "Контракт уже имеет использующийся номер ревизии" }
  alias_attribute :state, :priority # для поддержки MutableData

  # Если нет ревизий, то номер контракта = имя, иначе добавляем очередность ревизии
  def name
    priority === 0 ? contract.name : "#{contract.name}/#{priority}"
  end

  def head
    used ? name : "*" + name
  end

  def item
    super.merge({ description: description })
  end

  def card
    super.merge({ contract: contract.item, description: description, protocol_link: protocol_link, scan_link: scan_link, zip_link: zip_link, doc_link: doc_link, is_present: is_present, audits: audits })
  end

  def self.permitted_params
    super | [:contract_id, :protocol_link, :scan_link, :zip_link, :doc_link, :is_present]
  end
end
