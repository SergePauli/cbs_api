class Address < ApplicationRecord
  belongs_to :area

  validates_associated :area
  validates :value, presence: true
  validates :value, format: { with: /(?:(?:[а-яА-Я]+[,.])?\s*(ул|пер(?:.+?к)?|бул(?:.+?р)?|тупик|набережная|аллея|площ(.+?ь)?|проезд|кольцо)[.,]\s*[а-яА-Я\s]+,\s*(\d+\/\d+,)?\s*(д|кв)\.\s*\d)/,
                              message: "invalid address format" }, allow_blank: true
end
