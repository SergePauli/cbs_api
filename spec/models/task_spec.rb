require "rails_helper"

RSpec.describe Task, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state) }
  it { is_expected.to have_db_column(:used).of_type(:boolean) }
  it { is_expected.to have_db_column(:priority).of_type(:integer) }
  it { is_expected.to have_db_column(:list_key).of_type(:uuid) }

  it { is_expected.to have_db_column(:stage_id).of_type(:integer) }
  it { is_expected.to have_db_column(:task_kind_id).of_type(:integer) }

  fixtures :tasks, :task_kinds, :stages

  let (:task_new) {
    Task.new
  }

  it "Должна быть невалидной c невалидным id этапа" do
    task_new.stage_id = tasks(:krabcom_01_23_01_a).stage_id
    expect(task_new).not_to be_valid
    expect(task_new.errors[:stage]).not_to be_nil
    task_new.stage_id = 899 # несуществующий ID этапа
    expect(task_new).not_to be_valid
    expect(task_new.errors[:stage]).not_to be_nil
  end

  it "Должна быть невалидной с невалидным id вида задачи" do
    task_new.task_kind_id = task_kinds(:exam).id
    expect(task_new).not_to be_valid
    expect(task_new.errors[:task_kind]).not_to be_nil
  end

  it "должна быть уникальной комбинация id этапа и задачи" do
    task_new.stage_id = stages(:krabcom_01_23_01).id
    task_new.task_kind_id = task_kinds(:exam).id
    expect(task_new).not_to be_valid
    expect(task_new.errors[:stage]).not_to be_nil # "has already been taken"
    expect(task_new.errors[:task_kind]).not_to be_nil # "has already been taken"
  end

  let (:task) {
    tasks(:krabcom_01_23_01_a)
  }

  it "должна возвращать набор данных :item" do
    data = task.item
    expect(data[:id]).to eq task.id
    expect(data[:name]).to eq task.name
    expect(data[:priority]).to eq 1
  end

  it "должна возвращать набор данных :card" do
    data = task.card
    expect(data[:id]).to eq task.id
    expect(data[:head]).to include(task.task_kind.name)
    expect(data[:task_kind]).to eq task.task_kind.item
  end
end
