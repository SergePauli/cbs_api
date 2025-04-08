# Номер контракта и ссылки на документы
class Revision < MutableData

  # аудит изменений
  include Auditable

  belongs_to :contract, inverse_of: :revisions
  validates_associated :contract

  validates :contract, uniqueness: { scope: :priority }
  validates :priority, uniqueness: { scope: [:contract], message: "Контракт уже имеет использующийся номер ревизии" }
  alias_attribute :state, :priority # для поддержки MutableData

  # Если нет ревизий, то номер контракта = имя, иначе добавляем очередность ревизии
  def name
    priority === 0 ? contract.name : "#{contract.name}/#{priority}"
  end

  # шапка
  def head
    used ? name : "*" + name
  end

  # набор для списков
  def item
    super.merge({ description: description })
  end

  # заготовка (минимальный набор)
  def basement
    { id: id, used: used, priority: priority, list_key: list_key, description: description, protocol_link: protocol_link, scan_link: scan_link, zip_link: zip_link, doc_link: doc_link, is_present: is_present, is_signed: is_signed }
  end

  # карточка (полный набор)
  def card
    super.merge({ contract: contract.basement, audits: audits }).merge(basement)
  end

  def edit
    basement
  end

  def self.permitted_params
    super | [:contract_id, :protocol_link, :scan_link, :zip_link, :doc_link, :is_present, :is_signed, :description]
  end
end
