# реквизиты организаций
class Organization < NamedRecord
  # аудит изменений
  include Auditable

  belongs_to :ownership
  validates :name, presence: true
  validates :inn, presence: true, format: { with: /[0-9]{10}/, message: "Неверный код ИНН" }
  validates :kpp, format: { with: /[0-9]{9}/, message: "Неверный код КПП" }, allow_nil: true
  validates :ogrn, format: { with: /\A1[0-9]{12}/, message: "Неверный код ОГРН" }, allow_nil: true
  validates :okpo, format: { with: /[0-9]{8}/, message: "Неверный код ОКПО" }, allow_nil: true
  validates :oktmo, format: { with: /[0-9]{8,11}/, message: "Неверный код ОКТМО" }, allow_nil: true
  validates :okved, format: { with: /\A[0-9]{2}(.[0-9]{2,3}){0,1}(.[0-9]{2,3}){0,1}\z/, message: "Неверный код ОКВЭД" }, allow_nil: true
  validates :okogu, format: { with: /[0-9]{7}/, message: "Неверный код ОКОГУ" }, allow_nil: true
  validates :okfc, format: { with: /[0-9]{2}/, message: "Неверный код ОКФС" }, allow_nil: true
  validates :okopf, format: { with: /\A[1-7][0-9]{4}/, message: "Неверный код ОКОПФ" }, allow_nil: true
  validates :inn, uniqueness: { scope: :kpp }
  validates_associated :ownership

  # определяем дополнительный набор данных :financial
  def data_sets
    super.push(:financial)
  end

  def card
    super.merge({ name: name, full_name: full_name, inn: inn, kpp: kpp, ownership: ownership.item, audits: audits.map { |el| el.item } || [] })
  end

  # бухгалтерско-коммерческий набор
  def financial
    { inn: inn, kpp: kpp, ownership: ownership.item, ogrn: ogrn, okpo: okpo, oktmo: oktmo, okved: okved, okogu: okogu, okfc: okfc, okopf: okopf }
  end

  def self.permitted_params
    super | [:name, :full_name, :inn, :kpp, :ogrn, :okpo, :oktmo, :okved, :okogu, :okfc, :okopf, :ownership_id]
  end
end
