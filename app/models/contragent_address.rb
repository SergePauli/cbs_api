class ContragentAddress < MutableData
  # Не создаем дублей адресов
  include Stateable

  belongs_to :contragent, inverse_of: :contragent_addresses
  belongs_to :address
  validates_associated :contragent
  validates_associated :address
  validates :kind, uniqueness: { scope: [:contragent] }, if: -> { used? }
  alias_attribute :state, :address # для поддержки MutableData
  accepts_nested_attributes_for :address

  enum kind: [:real, :registred]
  validates :kind, presence: true

  def head
    (I18n.t kind) + ": " + super
  end

  def edit
    super.merge({ kind: kind, address_attributes: address.edit })
  end

  def self.permitted_params
    super | [:contragent_id, :kind, :address_id] | [address_attributes: Address.permitted_params]
  end
end
