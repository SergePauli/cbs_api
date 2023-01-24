class Contragent < ApplicationRecord
  # аудит изменений
  has_many :audits, primary_key: "obj_uuid", foreign_key: "obj_uuid"

  # привязка к реквизитам
  has_many :contragent_organizations, inverse_of: :contragent, dependent: :destroy, autosave: true
  has_one :contragent_organization, -> { where(used: true).order("id DESC") }
  accepts_nested_attributes_for :contragent_organizations, allow_destroy: true

  # общие контакты
  has_many :contragent_contacts, -> { order("priority DESC") }, inverse_of: :contragent, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :contragent_contacts, allow_destroy: true

  # сотрудники
  has_many :employees, -> { order("priority DESC") }, inverse_of: :contragent, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :employees, allow_destroy: true

  # адреса
  has_many :contragent_addresses, dependent: :destroy, inverse_of: :contragent
  accepts_nested_attributes_for :contragent_addresses, allow_destroy: true

  # Определяем наименование контрагента
  def name
    contragent_organization.head
  end

  # определяем дополнительный набор данных :financial
  def data_sets
    super.push(:financial)
  end

  def head
    "#{name}"
  end

  # карточка контрагента
  def card
    super.merge({ requisites: contragent_organization.card, description: description, obj_uuid: obj_uuid, audits: audits.map { |el| el.item } || [], contacts: contragent_contacts.filter { |el| el.used }.map { |el| el.item } || [], addresses: contragent_addresses.filter { |el| el.used }.map { |el| el.item } || [], employees: employees.filter { |el| el.used }.map { |el| el.item } || [] })
  end

  # налоговые и банковские реквизиты контрагента
  def financial
    { bank_name: bank_name, bank_bik: bank_bik, bank_account: bank_account, bank_cor_account: bank_cor_account }.merge(contragent_organization.organization.financial)
  end

  def self.permitted_params
    super | [:description, :obj_uuid, audit_attributes: Audit.permitted_params, contragent_organizations: ContragentOrganization.permitted_params, contragent_contacts_attributes: ContragentContact.permitted_params, employee_attributes: Employee.permitted_params, contragent_addresses_attributes: ContragentAddress.permitted_params]
  end
end
