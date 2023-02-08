class ContragentAddress < MutableData
  belongs_to :contragent, inverse_of: :contragent_addresses
  belongs_to :address
  validates_associated :contragent
  validates_associated :address
  validates :kind, uniqueness: { scope: [:contragent] }, if: -> { used? }
  alias_attribute :state, :address # для поддержки MutableData
  accepts_nested_attributes_for :address

  enum kind: [:real, :registred]
  validates :kind, presence: true

  # def used?
  #   used
  # end

  def head
    super + " (" + (I18n.t kind) + ")"
  end

  def item
    super.merge({ kind: kind })
  end

  def self.permitted_params
    super | [:contragent_id, :kind, :address_id, address_attributes: Address.permitted_params]
  end
end
