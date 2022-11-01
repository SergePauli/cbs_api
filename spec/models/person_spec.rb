require "rails_helper"

RSpec.describe Person, type: :model do
  fixtures :people, :namings, :contacts, :addresses, :person_names, :person_addresses, :person_contacts

  it "should be 3" do
    expect(Person.count).to eq 3
  end

  it "should have right names associations" do
    @person = people(:user)
    expect(@person.person_names.size).to eq 2
    expect(@person.person_name.id).to eq person_names(:user_new).id
    expect(@person.naming.surname).to eq namings(:user_new).surname
  end

  it "should have right address associations" do
    @person = people(:client)
    expect(@person.person_addresses.size).to eq 2
    expect(@person.person_address.id).to eq person_addresses(:client_new).id
    expect(@person.address.value).to eq addresses(:one).value
  end

  it "should have right contacts associations" do
    @person = people(:admin)
    expect(@person.person_contacts.size).to eq 4
  end

  it "should have right email" do
    @person = people(:admin)
    expect(@person.email.id).to eq contacts(:cbs_mail).id
  end

  it "should have right phone" do
    @person = people(:admin)
    expect(@person.phone.id).to eq contacts(:cbs_phone).id
  end
end
