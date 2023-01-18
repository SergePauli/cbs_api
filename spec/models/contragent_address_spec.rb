require "rails_helper"

RSpec.describe ContragentAddress, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData и добавленый
  it { is_expected.to respond_to(:state, :used, :priority, :kind) }

  fixtures :contragent_addresses, :addresses, :contragents

  before(:each) do
    @contragent_address = ContragentAddress.new
  end

  it "Должна быть невалидной c невалидным id контрагента" do
    @contragent_address.address_id = contragent_addresses(:kraskom_real).address_id
    expect(@contragent_address).not_to be_valid
    expect(@contragent_address.errors[:contragent]).not_to be_nil
    @contragent_address.contragent_id = 899 # this contragent ID not exist
    expect(@contragent_address).not_to be_valid
    expect(@contragent_address.errors[:contragent]).not_to be_nil
  end

  it "Должна быть невалидной c невалидным id адреса" do
    @contragent_address.contragent_id = contragent_addresses(:kraskom_real).contragent_id
    expect(@contragent_address).not_to be_valid
    expect(@contragent_address.errors[:address]).not_to be_nil
    @contragent_address.address_id = 899 # this address ID not exist
    expect(@contragent_address).not_to be_valid
    expect(@contragent_address.errors[:address]).not_to be_nil
  end

  it "should be uniq" do
    @contragent_address.contragent_id = contragent_addresses(:kraskom_real).contragent_id
    @contragent_address.address_id = contragent_addresses(:kraskom_real).address_id
    expect(@contragent_address).not_to be_valid
    expect(@contragent_address.errors[:address]).not_to be_nil # "has already been taken"
    expect(@contragent_address.errors[:contragent]).not_to be_nil # "has already been taken"
  end

  it "should not to be create dublicates of address" do
    @contragent_address.contragent_id = contragent_addresses(:med_rzd).contragent_id
    @contragent_address.address = Address.new
    @contragent_address.address.value = addresses(:moscow_1).value
    @contragent_address.address.area = addresses(:moscow_1).area
    @contragent_address.kind = :registred
    expect(@contragent_address).to be_valid
    expect(@contragent_address.address.id).to eq addresses(:moscow_1).id
  end

  it "должна создаваться запись c nested attributes" do
    @contragent_address = ContragentAddress.new({ contragent_id: 2, used: false, kind: :registred, address_attributes: { value: "г.Красноярск, пр-кт. Свободный, д.55", area_id: 24 } })
    @contragent_address.save
    expect(@contragent_address).not_to be_nil
    expect(@contragent_address).to be_valid
  end
end
