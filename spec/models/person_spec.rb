require "rails_helper"

RSpec.describe Person, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # добавленные методы
  it { is_expected.to respond_to(:full) }
  it { is_expected.to respond_to(:email, :phone) }

  fixtures :people, :namings, :contacts, :addresses, :person_names, :person_addresses, :person_contacts

  it "should be 3" do
    expect(Person.count).to eq 3
  end

  let (:person_user) {
    people(:user)
  }

  it "should have right names associations" do
    expect(person_user.person_names.size).to eq 2
    expect(person_user.person_name.id).to eq person_names(:user_new).id
    expect(person_user.naming.surname).to eq namings(:user_new).surname
  end

  it "Должна быть невалидной при невалидном ИНН" do
    person_user.inn = "invalid_inn"
    expect(person_user).not_to be_valid
    person_user.inn = "0123456789"
    expect(person_user).not_to be_valid
    person_user.inn = "012345678912"
    expect(person_user).to be_valid
  end

  it "should have one used names associations" do
    person_user.person_names[0].used = true
    expect(person_user).not_to be_valid
    expect(person_user.errors[:person_names]).not_to be_nil # "Personal name's data contains more or less then 1 actual record"
    person_user.person_names[0].used = false
    expect(person_user).to be_valid
    person_user.person_names[1].used = false
    expect(person_user).not_to be_valid # "No used names's data"
  end

  let (:person_client) {
    people(:client)
  }

  it "should have right address associations" do
    expect(person_client.person_addresses.size).to eq 2
    expect(person_client.person_address.id).to eq person_addresses(:client_new).id
    expect(person_client.address.value).to eq addresses(:one).value
  end

  let (:person_admin) {
    people(:admin)
  }
  it "should have right contacts associations" do
    expect(person_admin.person_contacts.size).to eq 4
  end

  it "should have right email" do
    expect(person_admin.email.id).to eq contacts(:cbs_mail).id
  end

  it "should have right phone" do
    expect(person_admin.phone.id).to eq contacts(:cbs_phone).id
  end

  it "should return right custom_data :head" do
    expect(person_admin.custom_data :head).to include(person_admin.naming.surname, person_admin.email.value, person_admin.naming.name[0] + ".")
  end

  it "should return right custom_data :card" do
    data = person_admin.custom_data :card
    expect(data[:email][:name]).to eq people(:admin).email.value
    expect(data[:phone][:name]).to eq people(:admin).phone.value
    expect(data[:address][:name]).to eq people(:admin).address.name
    expect(data[:contacts].size).to eq people(:admin).person_contacts.size - 1
    contact = data[:contacts][2]
    expect(contact[:name]).to eq person_contacts(:admin_mail).head
    expect(contact[:priority]).to eq person_contacts(:admin_mail).priority
  end

  it "should return right custom_data :full" do
    data = person_user.custom_data :full
    expect(data[:addresses].size).to eq 1
    expect(data[:namings].size).to eq 2
    naming = data[:namings][0]
    expect(naming[:name]).to eq person_names(:user).head
  end

  let (:new_person) {
    Person.create(person_contacts_attributes: [{ contact_attributes: { value: "test@mail.ru", type: "Email" }, used: true }], person_names_attributes: [{ used: true, naming_attributes: { name: "Апалон", surname: "Аполонов", patrname: "Григорьевич" } }], person_addresses_attributes: [{ used: false, address_attributes: { value: "г.Красноярск, пр-кт. Свободный, д.55", area_id: 24 } }])
  }
  it "должна создаваться запись c nested attributes" do
    expect(new_person).to be_valid
    expect(new_person.email).not_to be_nil
  end
end
