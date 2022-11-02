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

  def email
    person_contacts.find { |contact| contact.used && contact.type === "Email" }
  end

  def phone
    person_contacts.find { |contact| contact.used && contact.type === "Phone" }
  end
end
