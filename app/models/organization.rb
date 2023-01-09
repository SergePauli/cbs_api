# реквизиты организаций
class Organization < NamedRecord
  validates :name, presence: true
  validates :inn, presence: true, format: { with: /[0-9]{10}/, message: "Неверный код ИНН" }
  validates :kpp, format: { with: /[0-9]{9}/, message: "Неверный код КПП" }, allow_nil: true
  validates :inn, uniqueness: { scope: :kpp }

  def card
    super.merge({ name: name, full_name: full_name, inn: inn, kpp: kpp })
  end

  def self.permitted_params
    super | [:name, :full_name, :inn, :kpp]
  end
end
