require "rails_helper"
require "models/concerns/deadlineable_spec"
require "models/concerns/auditable_spec"

RSpec.describe Stage, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"
  it_behaves_like "deadlineable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state) }
  it { is_expected.to have_db_column(:used).of_type(:boolean) }
  it { is_expected.to have_db_column(:priority).of_type(:integer) }
  it { is_expected.to have_db_column(:list_key).of_type(:uuid) }

  # ссылки на модель-владельца
  it { is_expected.to have_db_column(:contract_id).of_type(:integer) }
  it { is_expected.to have_db_column(:task_kind_id).of_type(:integer) }
  it { is_expected.to have_db_column(:status_id).of_type(:integer) }

  # столбцы для отображения данных модели
  it { is_expected.to have_db_column(:cost).of_type(:float) }
  it { is_expected.to have_db_column(:completed_at).of_type(:date) }
  it { is_expected.to have_db_column(:deadline_at).of_type(:date) }
  it { is_expected.to have_db_column(:duration).of_type(:integer) }
  it { is_expected.to have_db_column(:sended_at).of_type(:date) }
  it { is_expected.to have_db_column(:is_sended).of_type(:boolean) }
  it { is_expected.to have_db_column(:ride_out_at).of_type(:date) }
  it { is_expected.to have_db_column(:is_ride_out).of_type(:boolean) }

  fixtures :stages, :contracts

  let (:stage_new) {
    Stage.new({ contract_id: contracts(:krabcom_01_23_01).id, priority: 1, task_kind_id: 4, list_key: "38fdfe7e-6eec-4ec4-bbf0-aa1b8500f3f5" })
  }

  it "Должна быть невалидной c невалидным id контракта" do
    stage_new.contract_id = nil
    expect(stage_new).not_to be_valid
    expect(stage_new.errors[:contract]).not_to be_nil
    stage_new.contract_id = 899 # несуществующий ID контракта
    expect(stage_new).not_to be_valid
    expect(stage_new.errors[:contract]).not_to be_nil
    #puts stage_new.errors.to_json
  end

  it "Должна быть невалидной c невалидным id задачи" do
    stage_new.task_kind_id = nil
    expect(stage_new).not_to be_valid
    expect(stage_new.errors[:task_kind]).not_to be_nil
    stage_new.task_kind_id = 899 # несуществующий ID задачи
    expect(stage_new).not_to be_valid
    expect(stage_new.errors[:task_kind]).not_to be_nil
  end

  it "должна быть уникальной комбинация id контракта и номера этапа" do
    stage_new.priority = 0
    expect(stage_new).not_to be_valid
    expect(stage_new.errors[:stage]).not_to be_nil # "has already been taken"
    expect(stage_new.errors[:priority]).not_to be_nil # "has already been taken"
  end

  it "должна штатно создаваться и обновляться, удаляться" do
    expect(stage_new.save).to eq true
    expect(stage_new.id).not_to be_nil
    expect(stage_new.head).to eq "01-23-10_Э1 Аттестация"
    stage_new.used = false
    stage_new.priority = 5
    expect(stage_new.save).to eq true
    expect(stage_new.card[:used]).to eq false
    expect(stage_new.card[:priority]).to eq 5
    expect(Stage.count).to eq 2
    stage_new.destroy
    expect(Stage.count).to eq 1
  end

  let (:test_one) {
    stages(:krabcom_01_23_01)
  }

  it "должна возвращать корректный набор данных :item" do
    data = test_one.item
    expect(data[:id]).to eq 1
    expect(data[:name]).to eq "01-23-10 Оценка эффективности"
    expect(data[:priority]).to eq 0
    test_one.priority = 1
    data = test_one.item
    expect(data[:name]).to eq "01-23-10_Э1 Оценка эффективности"
  end

  it "должна возвращать корректный набор данных :card" do
    data = test_one.card
    #puts data.to_json
    expect(data[:id]).to eq 1
    expect(data[:head]).to eq "01-23-10 Оценка эффективности"
    expect(data[:status][:id]).to eq 4
    expect(data[:status][:name]).to eq "Выполнен"
    expect(data[:status][:description]).to eq "Выполнены работы исполнителя"
    expect(data[:task_kind][:id]).to eq 2
    expect(data[:task_kind][:name]).to eq "Оценка эффективности"
    expect(data[:task_kind][:code]).to eq "01"
    expect(data[:cost]).to eq "70800.04"
    expect(data[:stage_orders].size).to eq 1
    expect(data[:performers].size).to eq 2
    expect(data[:payments].size).to eq 2
    expect(data[:duration]).to eq "30РДней"
    expect(data[:deadline_kind]).to eq "working_days"
    expect(data[:funded_at]).to be_nil
    expect(data[:deadline_at]).to eq Date.parse("2023-03-01")
    expect(data[:invoice_at]).to eq Date.parse("2023-01-27")
    expect(data[:ride_out_at]).to eq Date.parse("2023-03-01")
    expect(data[:is_ride_out]).to eq true
    expect(data[:completed_at]).to be_nil
    expect(data[:sended_at]).to be_nil
    expect(data[:is_sended_at]).to be_nil
    expect(data[:list_key]).to eq "7c69f63a-87f6-431d-9c5a-12df1004a499"
    expect(data[:summary]).not_to be_nil
  end

  it "должна возвращать корректный набор разрешенных параметров" do
    #puts Stage.permitted_params
    expect(Stage.permitted_params.size).to eq 22
  end
end
