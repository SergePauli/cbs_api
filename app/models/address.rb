class Address < NamedRecord
  belongs_to :area

  validates_associated :area
  validates :value, presence: true
  validates :value, format: { with: /(?:(?:[а-яА-Я]+[,.])?\s*(ул|пер(?:.+?к)?|бул(?:.+?р)?|пр-кт|проспект|тупик|набережная|аллея|площ(.+?ь)?|проезд|кольцо)[.,]\s*[а-яА-Я\s]+,\s*(\d+\/\d+,)?\s*(д|кв)\.\s*\d)/,
                              message: "invalid address format" }, allow_blank: true
  validates :value, uniqueness: { scope: :area }
  alias_attribute :name, :value

  def card
    super.merge({ area_id: area_id })
  end

  def self.permitted_params
    super | [:name, :value, :area_id]
  end
end
