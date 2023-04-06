# Номер контракта и ссылки на документы
class ContractNumber < MutableData
  # только одна запись может быть используемой
  include Singleable

  # аудит изменений
  include Auditable

  belongs_to :contract, inverse_of: :contract_numbers
  validates_associated :contract

  validates :contract, uniqueness: { scope: :priority }
  validates :used, uniqueness: { scope: [:contract], message: "Контракт уже имеет использующийся номер" }, if: -> { used? }
  alias_attribute :state, :number # для поддержки MutableData
  alias_attribute :main_model_id, :contract_id # для поддержки singleable

  before_save :generate_number, if: -> { number === nil }

  # Если нет доп.соглашений, то номер контракта = имя, иначе добавляем номер доп.соглашения
  def generate_number
    self.number = priority === 0 ? contract.name : "#{contract.name}/#{priority}"
  end

  def name
    number
  end

  def head
    used ? number : "*" + number
  end

  def card
    super.merge({ contract: contract.item, number: number, protocol_link: protocol_link, scan_link: scan_link, zip_link: zip_link, doc_link: doc_link, is_present: is_present, audits: audits })
  end

  def self.permitted_params
    super | [:contract_id, :protocol_link, :scan_link, :zip_link, :doc_link, :is_present]
  end
end
