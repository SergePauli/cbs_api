class Person < ApplicationRecord
  has_many :person_names, dependent: :destroy
  has_one :person_name, -> { where(used: true).order("id DESC") }
  has_one :naming, through: :person_name

  has_many :person_contacts, -> { order("priority DESC") }, dependent: :destroy

  has_many :person_addresses, dependent: :destroy
  has_one :person_address, -> { where(used: true).order("priority DESC") }
  has_one :address, through: :person_address

  def email
    person_contacts.find { |contact| contact.used && contact.type === "Email" }
  end

  def phone
    person_contacts.find { |contact| contact.used && contact.type === "Phone" }
  end
end
