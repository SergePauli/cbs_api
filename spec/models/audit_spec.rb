require "rails_helper"

RSpec.describe Audit, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  before(:each) do
    @audit = Audit.new
  end

  it "должна быть невалидной при отсутствии :obj_uuid в списке ошибок должно быть сообщение" do
    expect(@audit).not_to be_valid
    expect(@audit.errors[:obj_uuid]).not_to be_nil
  end

  it "должна быть невалидной при отсутствии :action в списке ошибок должно быть сообщение" do
    expect(@audit).not_to be_valid
    expect(@audit.errors[:action]).not_to be_nil
  end

  it "должна быть невалидной при отсутствии :obj_type в списке ошибок должно быть сообщение" do
    expect(@audit).not_to be_valid
    expect(@audit.errors[:obj_type]).not_to be_nil
  end

  it "должна быть невалидной при отсутствии :obj_name в списке ошибок должно быть сообщение" do
    expect(@audit).not_to be_valid
    expect(@audit.errors[:obj_name]).not_to be_nil
  end

  it "должна быть невалидной при отсутствии :user в списке ошибок должно быть сообщение" do
    expect(@audit).not_to be_valid
    expect(@audit.errors[:user]).not_to be_nil
  end

  let (:valid_audit) {
    Audit.new({ action: :added, obj_type: :contragent, obj_uuid: SecureRandom.uuid, obj_name: "test", user_id: 1 })
  }

  it "должна быть валидной при наличии всех обязательных аттрибутов" do
    expect(valid_audit).to be_valid
  end

  it "должна быть невалидной при невалидном :user в списке ошибок должно быть сообщение" do
    valid_audit.user_id = 999
    expect(valid_audit).not_to be_valid
    expect(valid_audit.errors[:user]).not_to be_nil
  end
end
