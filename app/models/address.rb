class Address < NamedRecord
  belongs_to :area

  validates_associated :area
  validates :value, presence: true
  validates :value, uniqueness: { scope: :area }
  alias_attribute :name, :value

  def card
    super.merge({ area_id: area_id })
  end

  def edit
    super.merge({ area_id: area_id })
  end

  def self.permitted_params
    super | [:name, :value, :area_id]
  end
end
