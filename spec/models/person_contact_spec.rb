require "rails_helper"

RSpec.describe PersonContact, type: :model do

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state, :used, :priority) }

  fixtures :person_contacts, :contacts, :people

  before(:each) do
    @person_contact = PersonContact.new
    @person_contact.list_key = SecureRandom.uuid
  end

  it "should require person" do
    @person_contact.contact_id = person_contacts(:admin_mail).contact_id
    expect(@person_contact).not_to be_valid
    expect(@person_contact.errors[:person]).not_to be_nil
    @person_contact.person_id = 899 # this person ID not exist
    expect(@person_contact).not_to be_valid
    expect(@person_contact.errors[:person]).not_to be_nil
  end

  it "should require contact" do
    @person_contact.person_id = person_contacts(:admin_mail).person_id
    expect(@person_contact).not_to be_valid
    expect(@person_contact.errors[:contact]).not_to be_nil
    @person_contact.contact_id = 899 # this address ID not exist
    expect(@person_contact).not_to be_valid
    expect(@person_contact.errors[:contact]).not_to be_nil
  end

  it "should be uniq" do
    @person_contact.person_id = person_contacts(:admin_mail).person_id
    @person_contact.contact_id = person_contacts(:admin_mail).contact_id
    expect(@person_contact).not_to be_valid
    expect(@person_contact.errors[:contact]).not_to be_nil # "has already been taken"
    expect(@person_contact.errors[:person]).not_to be_nil # "has already been taken"
  end

  it "should not to be create dublicates of contact" do
    @person_contact.person_id = person_contacts(:admin_mail).person_id
    @person_contact.contact = Contact.new
    @person_contact.contact.value = contacts(:client_mail).value
    @person_contact.contact.type = contacts(:client_mail).type
    expect(@person_contact).to be_valid
    expect(@person_contact.contact.id).to eq contacts(:client_mail).id
  end
end
