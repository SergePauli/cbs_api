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

  it "должна возвращать коректный набор данных :card" do
    data = stage_orders(:test_one).card
    #puts data.to_json
    expect(data[:id]).to eq 1
    expect(data[:head]).to include("Secret Net")
    expect(data[:stage][:id]).to eq 1
    expect(data[:stage][:name]).to eq "01-23-10 Оценка эффективности"
    expect(data[:stage][:priority]).to eq 0
    expect(data[:isecurity_tool][:id]).to eq 3
    expect(data[:isecurity_tool][:name]).to eq "Secret Net"
    expect(data[:isecurity_tool][:unit]).to eq "шт."
    expect(data[:organization][:id]).to eq 3
    expect(data[:organization][:name]).to eq "ООО \"Крабком-2\""
    expect(data[:order_status][:id]).to eq 1
    expect(data[:order_status][:name]).to eq "Запрошен счет"
    expect(data[:order_status][:description]).to be_nil
    expect(data[:amount]).to eq 2.0
    expect(data[:requested_at]).to eq Date.parse("2023-01-21")
    expect(data[:ordered_at]).to eq Date.parse("2023-01-21")
    expect(data[:order_number]).to eq "20230121_0001"
    expect(data[:payment_at]).to eq Date.parse("2023-02-01")
    expect(data[:received_at]).to eq Date.parse("2023-03-02")
    expect(data[:description]).to match "тестовый заказ СЗИ"

    expect(data[:summary]).not_to be_nil
  end
end
