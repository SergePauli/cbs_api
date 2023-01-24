require "rails_helper"

RSpec.describe Contragent, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # добавленные методы
  it { is_expected.to respond_to(:obj_uuid, :name) }

  fixtures :contragents, :contragent_organizations, :contragent_addresses, :contacts, :organizations, :employees

  let (:kraskom) {
    contragent = contragents(:kraskom)
    contragent.audits.push(Audit.new({ action: :added, obj_type: :contragent, obj_uuid: "cb972f50-37ef-43db-a871-2fbd48e60b1e", obj_name: "test", user_id: 1 }))
    contragent.save
    contragent
  }

  it "Должна быть валидна, для реквизитов реальной организации" do
    expect(kraskom).to be_valid
  end

  it "Должна выдавать корректный набор head" do
    expect(kraskom.head).to eq kraskom.name
  end

  it "Должна выдавать корректный набор item" do
    data = kraskom.item
    expect(data[:id]).to eq kraskom.id
    expect(data[:name]).to eq kraskom.head
  end

  it "Должна выдавать корректный набор card" do
    data = kraskom.card
    #puts data
    expect(data[:id]).to eq kraskom.id
    expect(data[:head]).to eq kraskom.head
    expect(data[:contacts].size).to eq 2
    expect(data[:contacts][0][:name]).to eq contacts(:client_mobile).value
    expect(data[:audits].size).to eq 1
    expect(data[:requisites][:organization][:inn]).to eq organizations(:kraskom).inn
    expect(data[:addresses].size).to eq 2
    expect(data[:addresses][0][:kind]).to eq contragent_addresses(:kraskom_real).kind
    expect(data[:addresses][0][:id]).to eq contragent_addresses(:kraskom_real).id
    expect(data[:employees].size).to eq 2
    expect(data[:employees][0][:id]).to eq employees(:client).id
    expect(data[:obj_uuid]).to eq kraskom.obj_uuid
  end

  it "Должна выдавать корректный набор financial" do
    data = kraskom.financial
    org = organizations(:kraskom)
    expect(data[:kpp]).to eq org.kpp
    expect(data[:inn]).to eq org.inn
    expect(data[:ogrn]).to eq org.ogrn
    expect(data[:bank_bik]).to eq kraskom.bank_bik
  end
end
