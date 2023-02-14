require "rails_helper"

RSpec.describe performer, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state, :used, :priority) }

  # добавлено
  it { is_expected.to respond_to(:description, :person, :department, :position) }

  fixtures :performers

  let (:performer) {
    Performer.new
  }

  it "Должна быть невалидной c невалидным id отдела" do
    performer.person_id = performers(:admin).person_id
    expect(performer).not_to be_valid
    expect(performer.errors[:department]).not_to be_nil
    performer.department_id = 899 # this department ID not exist
    expect(performer).not_to be_valid
    expect(performer.errors[:department]).not_to be_nil
  end

  it "Должна быть невалидной с невалидным id person" do
    performer.department_id = performers(:admin).department_id
    expect(performer).not_to be_valid
    expect(performer.errors[:person]).not_to be_nil
    performer.person_id = 899 # this person ID not exist
    expect(performer).not_to be_valid
    expect(performer.errors[:person]).not_to be_nil
  end

  it "Должна быть невалидной с невалидным id должности" do
    performer.department_id = performers(:admin).department_id
    performer.person_id = performers(:admin).person_id
    performer.position_id = 899 # this position ID not exist
    expect(performer).not_to be_valid
    expect(performer.errors[:position]).not_to be_nil
  end

  it "должна быть уникальной комбинация id person, отдела и должности" do
    performer.department_id = performers(:admin).department_id
    performer.person_id = performers(:admin).person_id
    performer.position_id = performers(:admin).position_id
    expect(performer).not_to be_valid
    expect(performer.errors[:department]).not_to be_nil # "has already been taken"
    expect(performer.errors[:person]).not_to be_nil # "has already been taken"
    expect(performer.errors[:position]).not_to be_nil # "has already been taken"
  end

  let (:test_performer) {
    performers(:admin)
  }

  it "должна возвращать набор данных :item" do
    data = test_performer.item
    expect(data[:id]).to eq test_performer.id
    expect(data[:name]).to eq test_performer.person.name
    expect(data[:position]).to eq test_performer.position.name
    expect(data[:contacts].size).to eq test_performer.person.person_contacts.size - 1
  end

  it "должна возвращать набор данных :card" do
    data = test_performer.card
    expect(data[:id]).to eq test_performer.id
    expect(data[:head]).to include(test_performer.person.name)
    expect(data[:position][:name]).to eq test_performer.position.name
    expect(data[:person][:id]).to eq test_performer.person.id
    expect(data[:person][:contacts].size).to eq test_performer.person.person_contacts.size - 1
  end
end
