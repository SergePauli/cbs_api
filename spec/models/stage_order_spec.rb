require "rails_helper"

RSpec.describe StageOrder, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state) }
  it { is_expected.to have_db_column(:used).of_type(:boolean) }
  it { is_expected.to have_db_column(:priority).of_type(:integer) }
  it { is_expected.to have_db_column(:list_key).of_type(:uuid) }

  it { is_expected.to have_db_column(:stage_id).of_type(:integer) }
  it { is_expected.to have_db_column(:isecurity_tool_id).of_type(:integer) }
  it { is_expected.to have_db_column(:order_status_id).of_type(:integer) }
  it { is_expected.to have_db_column(:organization_id).of_type(:integer) }
  it { is_expected.to have_db_column(:amount).of_type(:float) }
  it { is_expected.to have_db_column(:requested_at).of_type(:date) }
  it { is_expected.to have_db_column(:ordered_at).of_type(:date) }
  it { is_expected.to have_db_column(:payment_at).of_type(:date) }
  it { is_expected.to have_db_column(:received_at).of_type(:date) }
  it { is_expected.to have_db_column(:order_number).of_type(:string) }
  it { is_expected.to have_db_column(:description).of_type(:string) }

  fixtures :stage_orders, :stages, :order_statuses, :isecurity_tools, :organizations

  let (:new_stage_order) {
    StageOrder.new({ list_key: "38fdfe7e-6eec-4ec4-bbf0-aa1b8500f3f5" })
  }

  it "Должна быть невалидной c невалидным id этапа" do
    expect(new_stage_order.errors[:stage]).not_to be_nil
    new_stage_order.stage_id = 899 # несуществующий ID этапа
    expect(new_stage_order).not_to be_valid
    expect(new_stage_order.errors[:stage]).not_to be_nil
  end
  it "Должна быть невалидной c невалидным id организации-поставщика" do
    expect(new_stage_order.errors[:isecurity_tool]).not_to be_nil
    new_stage_order.isecurity_tool_id = 899 # несуществующий ID средства ЗИ
    expect(new_stage_order).not_to be_valid
    expect(new_stage_order.errors[:isecurity_tool]).not_to be_nil
  end

  it "Должна быть невалидной c невалидным id организации-поставщика" do
    expect(new_stage_order.errors[:organization]).not_to be_nil
    new_stage_order.organization_id = 899 # несуществующий ID организации-поставщика
    expect(new_stage_order).not_to be_valid
    expect(new_stage_order.errors[:organization]).not_to be_nil
  end

  it "Должна быть невалидной c невалидным id статуса заказа" do
    expect(new_stage_order.errors[:order_status]).not_to be_nil
    new_stage_order.order_status_id = 899 # несуществующий ID статуса
    expect(new_stage_order).not_to be_valid
    expect(new_stage_order.errors[:order_status]).not_to be_nil
  end

  it "должна быть невалидной с неуникальной комбинацией id этапа, СЗИ и поставщика" do
    new_stage_order.stage_id = stages(:krabcom_01_23_01).id
    new_stage_order.order_status_id = 1
    new_stage_order.isecurity_tool_id = isecurity_tools(:s_n).id
    new_stage_order.organization_id = organizations(:krabcom).id
    expect(new_stage_order).not_to be_valid
    expect(new_stage_order.errors[:stage]).not_to be_nil
    expect(new_stage_order.errors[:isecurity_tool]).not_to be_nil
    expect(new_stage_order.errors[:organization]).not_to be_nil
  end
end
