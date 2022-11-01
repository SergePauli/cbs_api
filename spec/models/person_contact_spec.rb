require "rails_helper"

RSpec.describe PersonContact, type: :model do
  fixtures :person_contacts

  before(:each) do
    @person_contact = PersonContact.new
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
end
