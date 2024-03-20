# # Валидатор наборов ФИО
# class NameValidator < ActiveModel::Validator
#   def validate(record)
#     used_count = 0
#     record.person_names.each { |person_name| used_count += 1 if person_name.used }
#     if used_count != 1
#       record.errors.add :person_names, "Персональные данные содержат более одного действующего набора ФИО"
#     end
#   end
# end

# Персональные данные участников (фио, адрес, контакты)
class Person < ApplicationRecord
  has_many :person_names, inverse_of: :person, dependent: :destroy, autosave: true
  has_one :person_name, -> { where(used: true).order("id DESC") }
  has_one :naming, through: :person_name

  has_many :person_contacts, -> { order("priority DESC") }, inverse_of: :person, autosave: true, dependent: :destroy

  has_many :person_addresses, dependent: :destroy, inverse_of: :person
  has_one :person_address, -> { where(used: true).order("priority DESC") }
  has_one :address, through: :person_address

  #validates_with NameValidator

  validates :person_contacts, presence: true
  validates :inn, format: { with: /[0-9]{12}/, message: "Неверный код ИНН" }, allow_nil: true

  # begin Принимаем атрибуты для связанных моделей
  accepts_nested_attributes_for :person_names, allow_destroy: true

  accepts_nested_attributes_for :person_addresses, allow_destroy: true

  accepts_nested_attributes_for :person_contacts, allow_destroy: true
  # получаем массив разрешенных параметров запросов на обновление
  def self.permitted_params
    super | [:inn, person_addresses_attributes: PersonAddress.permitted_params] | [person_contacts_attributes: PersonContact.permitted_params] | [person_names_attributes: PersonName.permitted_params]
  end

  # end

  def data_sets
    super.push(:financial)
  end

  def email
    get_contact_by_type "Email"
  end

  def phone
    get_contact_by_type "Phone"
  end

  def initials
    result = "#{naming.surname} #{naming.name[0]}."
    result += naming.patrname[0] + "." unless naming.patrname.blank?
    result
  end

  def head
    result = initials
    contact = email.nil? ? (phone.nil? ? "" : phone.value) : email.value
    result += " " + contact if contact != nil
  end

  def item
    { id: id, head: head, name: name }
  end

  def name
    initials
  end

  def basement
    { email: (email ? email.item : nil), phone: (phone ? phone.item : nil), full_name: person_name.naming.head }
  end

  def edit
    super.merge(basement).merge({ person_name: person_name.edit, person_names_attributes: person_names.map { |el| el.custom_data(:edit) } || [], person_addresses_attributes: person_addresses.map { |el| el.custom_data(:card) } || [], contacts: person_contacts.filter { |el| el.used }.map { |el| el.edit } || [] })
  end

  def card
    super.merge(basement).merge({ name: name, address: (address ? address.item : nil), contacts: person_contacts.filter { |el| el.used }.map { |el| el.custom_data(:item) } || [] })
  end

  def financial
    { inn: inn }
  end

  private

  def get_contact_by_type(type)
    p_contact = person_contacts.find { |contact| contact.used && contact.type === type }
    if p_contact
      p_contact.contact
    else
      nil
    end
  end
end
