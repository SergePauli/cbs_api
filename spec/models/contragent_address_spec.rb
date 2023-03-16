require "rails_helper"

RSpec.describe ContragentAddress, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData и добавленый аттрибут :kind
  it { is_expected.to respond_to(:state, :used, :priority, :kind) }

  fixtures :contragent_addresses, :addresses, :contragents

  it "Должна быть невалидной c невалидным list_key" do
    ca = ContragentAddress.new
    ca.address_id = contragent_addresses(:kraskom_real).address_id
    ca.contragent_id = contragent_addresses(:kraskom_real).contragent_id
    expect(ca).not_to be_valid
    expect(ca.errors[:list_key]).not_to be_nil
  end

  let (:contragent_address) do
    ca = ContragentAddress.new
    ca.list_key = SecureRandom.uuid
    ca
  end

  it "Должна быть невалидной c невалидным id контрагента" do
    contragent_address.address_id = contragent_addresses(:kraskom_real).address_id
    expect(contragent_address).not_to be_valid
    expect(contragent_address.errors[:contragent]).not_to be_nil
    contragent_address.contragent_id = 899 # this contragent ID not exist
    expect(contragent_address).not_to be_valid
    expect(contragent_address.errors[:contragent]).not_to be_nil
  end

  it "Должна быть невалидной c невалидным id адреса" do
    contragent_address.contragent_id = contragent_addresses(:kraskom_real).contragent_id
    expect(contragent_address).not_to be_valid
    expect(contragent_address.errors[:address]).not_to be_nil
    contragent_address.address_id = 899 # this address ID not exist
    expect(contragent_address).not_to be_valid
    expect(contragent_address.errors[:address]).not_to be_nil
  end

  it "Должна быть уникальной комбинация ID контрагента и типа адреса" do
    contragent_address.contragent_id = contragent_addresses(:kraskom_real).contragent_id
    contragent_address.address_id = addresses(:moscow_4).id
    contragent_address.kind = :real
    expect(contragent_address).not_to be_valid
    expect(contragent_address.errors[:contragent]).not_to be_nil
    expect(contragent_address.errors[:kind]).not_to be_nil # "has already been taken"
  end

  it "Не должено создаваться дублирующих записей адреса" do
    contragent_address.contragent_id = contragent_addresses(:med_rzd).contragent_id
    contragent_address.address = Address.new
    contragent_address.address.value = addresses(:moscow_1).value
    contragent_address.address.area = addresses(:moscow_1).area
    contragent_address.kind = :registred
    expect(contragent_address).not_to be_valid
  end

  it "должна создаваться запись c nested attributes" do
    contragent_address = ContragentAddress.new({ contragent_id: 2, used: false, kind: :registred, address_attributes: { value: "г.Красноярск, пр-кт. Свободный, д.55", area_id: 24 }, list_key: SecureRandom.uuid })
    contragent_address.save
    expect(contragent_address).not_to be_nil
    expect(contragent_address).to be_valid
  end

  it "должна генерировать корректный head" do
    expect(contragent_addresses(:kraskom_real).head).to include("(регистрации)")
  end
end
