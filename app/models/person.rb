class NameValidator < ActiveModel::Validator
  def validate(record)
    used_count = 0
    record.person_names.each { |person_name| used_count += 1 if person_name.used }
    if used_count != 1
      record.errors.add :person_names, "Personal name's data contains more or less then 1 actual record"
    end
  end
end

class Person < ApplicationRecord
  has_many :person_names, dependent: :destroy
  has_one :person_name, -> { where(used: true).order("id DESC") }
  has_one :naming, through: :person_name

  has_many :person_contacts, -> { order("priority DESC") }, dependent: :destroy

  has_many :person_addresses, dependent: :destroy
  has_one :person_address, -> { where(used: true).order("priority DESC") }
  has_one :address, through: :person_address

  validates_with NameValidator

  def data_sets
    super.push(:full)
  end

  def email
    get_contact_by_type "Email"
  end

  def phone
    get_contact_by_type "Phone"
  end

  def head
    result = "#{naming.surname} #{naming.name[0]}."
    result += naming.patrname[0] + "." if naming.patrname
    contact = email.value || phone.value
    result += " " + contact if contact
  end

  def card
    super.merge({ email: email.custom_data(:card), phone: phone.custom_data(:card), address: address.custom_data(:card), contacts: person_contacts.map { |el| el.custom_data(:item) } })
  end

  def full
    card.merge({ namings: person_names.map { |el| el.custom_data(:item) }, addresses: person_addresses.map { |el| el.custom_data(:item) } })
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
