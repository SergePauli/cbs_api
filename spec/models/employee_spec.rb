require "rails_helper"

RSpec.describe Employee, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state, :used, :priority) }

  # добавлено
  it { is_expected.to respond_to(:description, :person, :contragent, :position) }

  fixtures :employees

  let (:employee) {
    Employee.new
  }

  it "Должна быть невалидной c невалидным id контрагента" do
    employee.person_id = employees(:admin).person_id
    expect(employee).not_to be_valid
    expect(employee.errors[:contragent]).not_to be_nil
    employee.contragent_id = 899 # this contragent ID not exist
    expect(employee).not_to be_valid
    expect(employee.errors[:contragent]).not_to be_nil
  end

  it "Должна быть невалидной с невалидным id person" do
    employee.contragent_id = employees(:admin).contragent_id
    expect(employee).not_to be_valid
    expect(employee.errors[:person]).not_to be_nil
    employee.person_id = 899 # this person ID not exist
    expect(employee).not_to be_valid
    expect(employee.errors[:person]).not_to be_nil
  end

  it "Должна быть невалидной с невалидным id должности" do
    employee.contragent_id = employees(:admin).contragent_id
    employee.person_id = employees(:admin).person_id
    employee.position_id = 899 # this position ID not exist
    expect(employee).not_to be_valid
    expect(employee.errors[:position]).not_to be_nil
  end

  it "должна быть уникальной комбинация id person, контрагента и должности" do
    employee.contragent_id = employees(:admin).contragent_id
    employee.person_id = employees(:admin).person_id
    employee.position_id = employees(:admin).position_id
    expect(employee).not_to be_valid
    expect(employee.errors[:contragent]).not_to be_nil # "has already been taken"
    expect(employee.errors[:person]).not_to be_nil # "has already been taken"
    expect(employee.errors[:position]).not_to be_nil # "has already been taken"
  end

  let (:test_employee) {
    employees(:admin)
  }

  it "должна возвращать набор данных :item" do
    data = test_employee.item
    expect(data[:id]).to eq test_employee.id
    expect(data[:name]).to eq test_employee.person.name
    expect(data[:position]).to eq test_employee.position.name
    expect(data[:contacts].size).to eq test_employee.person.person_contacts.size - 1
  end

  it "должна возвращать набор данных :card" do
    data = test_employee.card
    expect(data[:id]).to eq test_employee.id
    expect(data[:head]).to include(test_employee.person.name)
    expect(data[:position][:name]).to eq test_employee.position.name
    expect(data[:person][:id]).to eq test_employee.person.id
    expect(data[:person][:contacts].size).to eq test_employee.person.person_contacts.size - 1
  end
end
