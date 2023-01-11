require "rails_helper"

RSpec.describe Contragent, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # добавленные методы
  it { is_expected.to respond_to(:obj_type, :obj_uuid) }

  fixtures :contragents

  let (:kraskom) {
    contragent = contragents(:kraskom)
    contragent.audits.push(Audit.new({ action: :added, obj_type: :contragent, obj_uuid: "cb972f50-37ef-43db-a871-2fbd48e60b1e", obj_name: "test", user_id: 1 }))
    contragent.save
    contragent
  }

  it "Должна быть валидна, для реквизитов реальной организации" do
    expect(kraskom).to be_valid
  end

  it "Должна быть валидна, для реквизитов реальной организации" do
    expect(kraskom).to be_valid
  end
end
