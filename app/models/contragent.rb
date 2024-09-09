class Contragent < ApplicationRecord
  # аудит изменений
  include Auditable

  # Комментирование
  include Commentable

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
  has_one :real_addr, -> { where(used: true).where(kind: :real).order("id DESC") }, class_name: "ContragentAddress"
  has_one :registred_addr, -> { where(used: true).where(kind: :registred).order("id DESC") }, class_name: "ContragentAddress"
  accepts_nested_attributes_for :contragent_addresses, allow_destroy: true

  # контракты
  has_many :contracts, -> { order("id DESC") }

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

  def item
    super.merge({ description: description })
  end

  # карточка контрагента
  def card
    super.merge({ requisites: contragent_organization.card, description: description, obj_uuid: obj_uuid, audits: audits.map { |el| el.card } || [], comments: comments.map { |el| el.item } || [], contacts: contragent_contacts.filter { |el| el.used }.map { |el| el.edit } || [], real_addr: real_addr.nil? ? nil : real_addr.edit, registred_addr: registred_addr.nil? ? nil : registred_addr.edit, region: real_addr.nil? ? nil : real_addr.address.area.item, employees: employees.nil? ? nil : employees.map { |el| el.item }, contracts: contracts.nil? ? nil : contracts.map { |el| el.item } })
  end

  # для редактирования контрагента
  def edit
    super.merge({ requisites: contragent_organization.card, description: description, obj_uuid: obj_uuid, contacts: contragent_contacts.filter { |el| el.used }.map { |el| el.edit } || [], real_addr: real_addr.nil? ? nil : real_addr.edit, registred_addr: registred_addr.nil? ? nil : registred_addr.edit, employees: employees.nil? ? nil : employees.map { |el| el.edit }})
  end

  def uid
    { id: id, name: head, uid: obj_uuid}
  end

  # налоговые и банковские реквизиты контрагента
  def financial
    { bank_name: bank_name, bank_bik: bank_bik, bank_account: bank_account, bank_cor_account: bank_cor_account }.merge(contragent_organization.organization.financial)
  end

  # поддержка универсального контроллера
  def self.permitted_params
    super | [:bank_name, :bank_bik, :bank_account, :bank_cor_account, :description, :obj_uuid] | [contragent_organizations_attributes: ContragentOrganization.permitted_params] | [contragent_contacts_attributes: ContragentContact.permitted_params] | [employees_attributes: Employee.permitted_params] | [contragent_addresses_attributes: ContragentAddress.permitted_params] | [comments_attributes: Comment.permitted_params]
  end
end
