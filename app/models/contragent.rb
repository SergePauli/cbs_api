class Contragent < ApplicationRecord
  # аудит изменений
  has_many :audits, primary_key: "obj_uuid", foreign_key: "obj_uuid"

  # привязка к юр.лицу
  has_many :contragent_organizations, inverse_of: :contragent, dependent: :destroy, autosave: true
  has_one :contragent_organization, -> { where(used: true).order("id DESC") }
  accepts_nested_attributes_for :contragent_organizations, allow_destroy: true

  # привязка к физ.лицу
  belongs_to :person, optional: true
  validates_associated :person
  accepts_nested_attributes_for :person

  # общие контакты
  has_many :contragent_contacts, -> { order("priority DESC") }, inverse_of: :contragent, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :contragent_contacts, allow_destroy: true

  # сотрудники
  has_many :employees, -> { order("priority DESC") }, inverse_of: :contragent, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :employees, allow_destroy: true

  # адреса
  has_many :contragent_addresses, dependent: :destroy, inverse_of: :contragent
  accepts_nested_attributes_for :contragent_addresses, allow_destroy: true

  # тип контрагента
  enum obj_type: [:organization, :person]
  validates :obj_type, presence: true

  def obj_type_name
    case obj_type
    when "organization"
      "юр.лицо"
    when "person"
      "физ.лицо"
    end
  end

  def name
    case obj_type
    when "organization"
      contragent_organization.head
    when "person"
      person.head
    end
  end

  def requisites
    case obj_type
    when "organization"
      contragent_organization
    when "person"
      person
    end
  end

  # определяем дополнительный набор данных :financial
  def data_sets
    super.push(:financial)
  end

  def head
    "#{obj_type_name}: #{name}"
  end

  # карточка контрагента
  def card
    super.merge({ requisites: requisites.card, description: description, obj_uuid: obj_uuid, audits: audits.map { |el| el.item } || [], contacts: contragent_contacts.map { |el| el.item } || [], addresses: contragent_addresses.map { |el| el.item } || [], employees: employees.map { |el| el.item } || [] })
  end

  # налоговые и банковские реквизиты контрагента
  def financial
    { bank_name: bank_name, bank_bik: bank_bik, bank_account: bank_account, bank_cor_account: bank_cor_account }.merge(requisites.financial)
  end

  def self.permitted_params
    super | [:person_id, :description, :obj_uuid, :obj_type, audit_attributes: Audit.permitted_params, contragent_organizations: ContragentOrganization.permitted_params, contragent_contacts_attributes: ContragentContact.permitted_params, person_attributes: Person.permitted_params, employee_attributes: Employee.permitted_params, contragent_addresses_attributes: ContragentAddress.permitted_params]
  end
end
