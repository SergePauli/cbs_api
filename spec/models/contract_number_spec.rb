require "rails_helper"
require "models/concerns/auditable_spec"
require "models/concerns/singleable_spec"
RSpec.describe ContractNumber, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"
  # поддерживает единичность активного состояния
  it_behaves_like "singleable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state) }
  it { is_expected.to have_db_column(:used).of_type(:boolean) }
  it { is_expected.to have_db_column(:priority).of_type(:integer) }
  it { is_expected.to have_db_column(:list_key).of_type(:uuid) }

  # ссылки на модель-владельца
  it { is_expected.to have_db_column(:contract_id).of_type(:integer) }

  # столбцы для отображения данных модели
  it { is_expected.to have_db_column(:number).of_type(:string) }
  it { is_expected.to have_db_column(:protocol_link).of_type(:string) }
  it { is_expected.to have_db_column(:scan_link).of_type(:string) }
  it { is_expected.to have_db_column(:doc_link).of_type(:string) }
  it { is_expected.to have_db_column(:zip_link).of_type(:string) }
  it { is_expected.to have_db_column(:is_present).of_type(:boolean) }

  fixtures :contract_numbers, :contracts

  let (:number_new) {
    ContractNumber.new({ contract_id: contracts(:krabcom_01_23_01).id, priority: 1, list_key: "38fdfe7e-6eec-4ec4-bbf0-aa1b8500f3f5" })
  }

  it "Должна быть невалидной c невалидным id контракта" do
    number_new.contract_id = nil
    expect(number_new).not_to be_valid
    expect(number_new.errors[:contract]).not_to be_nil
    number_new.contract_id = 899 # несуществующий ID контракта
    expect(number_new).not_to be_valid
    expect(number_new.errors[:contract]).not_to be_nil
  end

  it "должна быть уникальной комбинация id контракта и номера допа" do
    number_new.priority = 0
    expect(number_new).not_to be_valid
    expect(number_new.errors[:contract]).not_to be_nil # "has already been taken"
    expect(number_new.errors[:priority]).not_to be_nil # "has already been taken"
    #puts number_new.errors.to_json
  end

  it "должна штатно создаваться и обновляться, удаляться" do
    expect(number_new.save).to eq true
    expect(number_new.id).not_to be_nil
    expect(number_new.head).to eq "01-23-10/1"
    number_new.priority = 2
    number_new.number = nil
    expect(number_new.save).to eq true
    expect(number_new.card[:priority]).to eq 2
    expect(number_new.card[:head]).to eq "01-23-10/2"
    expect(ContractNumber.count).to eq 2
    number_new.destroy
    expect(ContractNumber.count).to eq 1
  end

  let (:test_one) {
    contract_numbers(:c_01_23_01)
  }

  it "должна возвращать корректный набор данных :item" do
    data = test_one.item
    expect(data[:id]).to eq 1
    expect(data[:name]).to eq "01_23_01"
    expect(data[:priority]).to eq 0
  end

  it "должна возвращать корректный набор данных :card" do
    data = test_one.card
    #puts data.to_json
    expect(data[:id]).to eq 1
    expect(data[:head]).to eq "01_23_01"
    expect(data[:contract][:id]).to eq 1
    expect(data[:contract][:name]).to eq "01-23-10"
    expect(data[:number]).to eq "01_23_01"
    expect(data[:protocol_link]).to eq "ссылка_на_протокол"
    expect(data[:scan_link]).to eq "ссылка на скан"
    expect(data[:doc_link]).to eq "ссылка на документ"
    expect(data[:zip_link]).to eq "ссылка на архив"
    expect(data[:is_present]).to eq false
    expect(data[:list_key]).to eq "7c69f63a-87f6-431d-9c5a-12df1004a449"
    expect(data[:summary]).not_to be_nil
  end

  it "должна возвращать корректный набор разрешенных параметров" do
    expect(ContractNumber.permitted_params.size).to eq 11
  end
end
