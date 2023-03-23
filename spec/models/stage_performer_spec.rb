require "rails_helper"

RSpec.describe StagePerformer, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state) }
  it { is_expected.to have_db_column(:used).of_type(:boolean) }
  it { is_expected.to have_db_column(:priority).of_type(:integer) }
  it { is_expected.to have_db_column(:list_key).of_type(:uuid) }

  it { is_expected.to have_db_column(:stage_id).of_type(:integer) }
  it { is_expected.to have_db_column(:performer_id).of_type(:integer) }

  fixtures :stage_performers, :performers, :stages, :contracts

  let (:test_new) {
    StagePerformer.new({ list_key: "7c69f63a-87f6-431d-9c5a-12df1004a500" })
  }

  it "Должна быть невалидной c невалидным id этапа" do
    test_new.performer_id = performers(:user).id
    expect(test_new).not_to be_valid
    expect(test_new.errors[:stage]).not_to be_nil
    test_new.stage_id = 899 # несуществующий ID этапа
    expect(test_new).not_to be_valid
    expect(test_new.errors[:stage]).not_to be_nil
  end

  it "Должна быть невалидной с невалидным id исполнителя" do
    test_new.stage_id = stages(:krabcom_01_23_01).id
    expect(test_new).not_to be_valid
    expect(test_new.errors[:performer]).not_to be_nil
  end

  it "должна быть уникальной комбинация id этапа и задачи" do
    test_new.stage_id = stage_performers(:test_one).stage_id
    test_new.performer_id = stage_performers(:test_one).performer_id
    expect(test_new).not_to be_valid
    #puts test_new.errors.to_json
    expect(test_new.errors[:stage]).not_to be_nil # "has already been taken"
    expect(test_new.errors[:performer]).not_to be_nil # "has already been taken"
  end

  it "должна штатно создаваться и обновляться (c запоминанием :stage_id, :performer, :priority, :used), удаляться" do
    test_new.stage_id = stage_performers(:test_one).stage_id
    test_new.performer_id = performers(:client).id
    expect(test_new.save).to eq true
    expect(test_new.id).not_to be_nil
    expect(test_new.head).to eq "Иванов Иван, начальник отдела ОЗИ"
    test_new.used = false
    test_new.priority = 5
    expect(test_new.save).to eq true
    expect(test_new.card[:used]).to eq false
    expect(test_new.card[:priority]).to eq 5
    expect(StagePerformer.count).to eq 3
    test_new.destroy
    expect(StagePerformer.count).to eq 2
  end

  let (:test_performer) {
    stage_performers(:test_one)
  }

  it "должна возвращать набор данных :item" do
    data = test_performer.item
    expect(data[:id]).to eq test_performer.id
    expect(data[:name]).to eq test_performer.head
    expect(data[:priority]).to eq 0
  end

  it "должна возвращать набор данных :card" do
    data = test_performer.card
    expect(data[:id]).to eq test_performer.id
    expect(data[:head]).to include(test_performer.name)
    expect(data[:performer]).to eq test_performer.performer.item
    expect(data[:stage]).to eq test_performer.stage.item
  end
end
