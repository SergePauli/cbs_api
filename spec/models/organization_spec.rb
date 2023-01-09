require "rails_helper"

RSpec.describe Organization, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # добавленные методы
  it { is_expected.to respond_to(:name, :inn, :full_name, :kpp) }

  fixtures :organizations

  let (:kraskom) {
    organizations(:kraskom)
  }

  it "Должна быть валидна, для реквизитов реальной организации" do
    expect(kraskom).to be_valid
    kraskom.kpp = nil
    expect(kraskom).to be_valid
  end

  it "Должна быть невалидна, с недопустимым ИНН" do
    kraskom.inn = "not_valid"
    expect(kraskom).not_to be_valid
    kraskom.inn = "0123456"
    expect(kraskom).not_to be_valid
  end

  it "Должна быть невалидна, с недопустимым КПП" do
    kraskom.kpp = "not_valid"
    expect(kraskom).not_to be_valid
    kraskom.kpp = "0123456"
    expect(kraskom).not_to be_valid
  end

  it "Должна быть невалидна, без наименования" do
    kraskom.name = nil
    expect(kraskom).not_to be_valid
  end
  it "Должна быть невалидна, c уже существующим наименованием" do
    @org = Organization.new({ name: kraskom.name, inn: "01234567891" })
    expect(@org).not_to be_valid
  end
  it "Должна быть невалидна, c уже существующими ИНН и КПП" do
    @org = Organization.new({ name: "new organization", inn: kraskom.inn, kpp: kraskom.kpp })
    expect(@org).not_to be_valid
  end
  it "Должна возвращать набор данных :card" do
    data = kraskom.card
    expect(data[:inn]).to eq kraskom.inn
    expect(data[:kpp]).to eq kraskom.kpp
    expect(data[:full_name]).to eq kraskom.full_name
    expect(data[:head]).to eq kraskom.name
  end

  it "Должна возвращать набор данных :item" do
    data = kraskom.item
    expect(data[:id]).to eq kraskom.id
    expect(data[:name]).to eq kraskom.name
  end
end
