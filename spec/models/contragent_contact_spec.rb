require "rails_helper"

RSpec.describe ContragentContact, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state, :used, :priority) }
  # добавлено
  it { is_expected.to respond_to(:description) }

  fixtures :contragent_contacts, :contacts, :contragents

  before(:each) do
    @contragent_contact = ContragentContact.new
    @contragent_contact.list_key = SecureRandom.uuid
  end

  it "Должна быть невалидной c невалидным id контрагента" do
    @contragent_contact.contact_id = contragent_contacts(:org_mail).contact_id
    expect(@contragent_contact).not_to be_valid
    expect(@contragent_contact.errors[:contragent]).not_to be_nil
    @contragent_contact.contragent_id = 899 # this contragent ID not exist
    expect(@contragent_contact).not_to be_valid
    expect(@contragent_contact.errors[:contragent]).not_to be_nil
  end

  it "Должна быть невалидной с невалидным id контакта" do
    @contragent_contact.contragent_id = contragent_contacts(:org_mail).contragent_id
    expect(@contragent_contact).not_to be_valid
    expect(@contragent_contact.errors[:contact]).not_to be_nil
    @contragent_contact.contact_id = 899 # this address ID not exist
    expect(@contragent_contact).not_to be_valid
    expect(@contragent_contact.errors[:contact]).not_to be_nil
  end

  it "должна быть уникальной комбинация id контакта и контрагента" do
    @contragent_contact.contragent_id = contragent_contacts(:org_mail).contragent_id
    @contragent_contact.contact_id = contragent_contacts(:org_mail).contact_id
    expect(@contragent_contact).not_to be_valid
    expect(@contragent_contact.errors[:contact]).not_to be_nil # "has already been taken"
    expect(@contragent_contact.errors[:contragent]).not_to be_nil # "has already been taken"
  end

  it "Не должено создаваться дублирующих контактов" do
    @contragent_contact.contragent_id = contragents(:med_rzd).id
    @contragent_contact.contact = Contact.new
    @contragent_contact.contact.value = contacts(:client_mail).value
    @contragent_contact.contact.type = contacts(:client_mail).type
    expect(@contragent_contact).not_to be_valid
    expect(@contragent_contact.errors[:contact]).not_to be_nil # "has already been taken"
  end
end
