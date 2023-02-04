require "rails_helper"

RSpec.describe PersonAddress, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state, :used, :priority) }

  fixtures :person_addresses, :addresses, :people

  before(:each) do
    @person_address = PersonAddress.new
    @person_address.list_key = SecureRandom.uuid
  end

  it "should require person" do
    @person_address.address_id = person_addresses(:admin).address_id
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:person]).not_to be_nil
    @person_address.person_id = 899 # this person ID not exist
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:person]).not_to be_nil
  end

  it "should require address" do
    @person_address.person_id = person_addresses(:admin).person_id
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:address]).not_to be_nil
    @person_address.address_id = 899 # this address ID not exist
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:address]).not_to be_nil
  end

  it "should be uniq" do
    @person_address.person_id = person_addresses(:admin).person_id
    @person_address.address_id = person_addresses(:admin).address_id
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:address]).not_to be_nil # "has already been taken"
    expect(@person_address.errors[:person]).not_to be_nil # "has already been taken"
  end

  it "should not to be create dublicates of address" do
    @person_address.person_id = person_addresses(:admin).person_id
    @person_address.address = Address.new
    @person_address.address.value = addresses(:moscow_1).value
    @person_address.address.area = addresses(:moscow_1).area
    expect(@person_address).to be_valid
    expect(@person_address.address.id).to eq addresses(:moscow_1).id
  end

  it "должна создаваться запись c nested attributes" do
    @person_address = PersonAddress.new({ person_id: 1, used: false, address_attributes: { value: "г.Красноярск, пр-кт. Свободный, д.55", area_id: 24 }, list_key: SecureRandom.uuid })
    @person_address.save
    expect(@person_address).not_to be_nil
    expect(@person_address).to be_valid
  end
end
