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

  it "should have one used names associations" do
    @person = people(:user)
    @person.person_names[0].used = true
    expect(@person).not_to be_valid
    expect(@person.errors[:person_names]).not_to be_nil # "Personal name's data contains more or less then 1 actual record"
    @person.person_names[0].used = false
    expect(@person).to be_valid
    @person.person_names[1].used = false
    expect(@person).not_to be_valid # "No used names's data"
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

  it "should return right custom_data :head" do
    expect(people(:admin).custom_data :head).to include(people(:admin).naming.surname, people(:admin).email.value, people(:admin).naming.name[0] + ".")
  end

  it "should return right custom_data :card" do
    data = people(:admin).custom_data :card
    expect(data[:email][:head]).to eq people(:admin).email.value
    expect(data[:phone][:head]).to eq people(:admin).phone.value
    expect(data[:address][:head]).to eq people(:admin).address.value
    expect(data[:contacts].size).to eq 4
    contact = data[:contacts][3]
    expect(contact[:name]).to eq person_contacts(:admin_mail).head
    expect(contact[:used]).to eq person_contacts(:admin_mail).used
    expect(contact[:priority]).to eq person_contacts(:admin_mail).priority
  end

  it "should return right custom_data :full" do
    data = people(:user).custom_data :full
    expect(data[:addresses].size).to eq 1
    expect(data[:namings].size).to eq 2
    naming = data[:namings][0]
    expect(naming[:used]).to eq person_names(:user).used
  end
end
