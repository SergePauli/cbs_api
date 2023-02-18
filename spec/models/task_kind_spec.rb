require "rails_helper"

RSpec.describe TaskKind, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # добавлено
  it { is_expected.to respond_to(:description, :cost, :duration) }

  fixtures :task_kinds

  let (:new_value) {
    TaskKind.new
  }

  it "должна содержать name" do
    new_value.name = nil
    expect(new_value).not_to be_valid
    expect(new_value.errors[:name]).not_to be_nil
  end

  let (:test_value) {
    task_kinds(:documents)
  }

  it "должна быть валидной для тестового примера" do
    expect(test_value).to be_valid
  end
  it "name должно быть уникальным" do
    new_value.name = test_value.name
    expect(new_value).not_to be_valid
    expect(new_value.errors[:name]).not_to be_nil
  end

  it "должна выдаваться ошибка, если code не соответствует формату типа контракта" do
    test_value.code = "Z3"
    expect(test_value).not_to be_valid
    expect(test_value.errors[:code]).not_to be_nil
    test_value.code = "79"
    expect(test_value).to be_valid
  end

  it "должна удаляться" do
    to_destroy = task_kinds(:exam)
    to_destroy.destroy
    expect { to_destroy.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "должна возвращать набор данных :head" do
    expect(test_value.custom_data :head).to eq test_value.name
  end

  it "должна возвращать набор данных :item c кодом типа контракта, если он был указан" do
    data = test_value.custom_data :item
    expect(data[:name]).to eq test_value.name
    expect(data[:id]).to eq test_value.id
    expect(data[:code]).to be_nil
    expect(data[:created_at]).to be_nil
    test_value.code = "79"
    data = test_value.custom_data :item
    expect(data[:code]).to eq "79"
  end

  it "должна возвращать набор данных :summary" do
    data = test_value.custom_data :summary
    expect(data[:created].to_formatted_s(:short)).to eq test_value.created_at.to_formatted_s(:short)
    expect(data[:updated].to_formatted_s(:short)).to eq test_value.updated_at.to_formatted_s(:short)
    expect(data[:id]).to be_nil
  end

  it "должна возвращать набор данных :card" do
    data = test_value.custom_data :card
    expect(data[:summary][:created].to_formatted_s(:short)).to eq test_value.created_at.to_formatted_s(:short)
    expect(data[:summary][:updated].to_formatted_s(:short)).to eq test_value.updated_at.to_formatted_s(:short)
    expect(data[:id]).to eq test_value.id
    expect(data[:description]).to eq test_value.description
    expect(data[:cost]).to eq test_value.cost
    expect(data[:duration]).to eq test_value.duration
    expect(data[:head]).to eq test_value.name
  end

  it "должна возвращать false для неподдерживаемого набора данных" do
    expect(test_value.custom_data :none).to eq false
  end
end
