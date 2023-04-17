require "rails_helper"
require "models/concerns/executable_spec"
require "models/concerns/auditable_spec"
require "models/concerns/commentable_spec"
RSpec.describe Contract, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"
  # комменты
  it_behaves_like "commentable"
  # статусы, сроки, задачи
  it_behaves_like "executable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # ссылки на модель-владельца
  it { is_expected.to have_db_column(:contragent_id).of_type(:integer) }

  # столбцы для отображения данных модели
  it { is_expected.to have_db_column(:signed_at).of_type(:date) }
  it { is_expected.to have_db_column(:order).of_type(:integer) }
  it { is_expected.to have_db_column(:year).of_type(:integer) }
  it { is_expected.to have_db_column(:code).of_type(:string) }
  it { is_expected.to have_db_column(:governmental).of_type(:boolean) }

  fixtures :contracts

  let (:test_one) {
    contracts(:krabcom_01_23_01)
  }

  it "должна проверять id контрагента" do
    test_one.contragent_id = nil
    expect(test_one).not_to be_valid
    expect(test_one.errors[:contragent]).not_to be_nil
    test_one.contragent_id = 899 # несуществующий ID контракта
    expect(test_one).not_to be_valid
    expect(test_one.errors[:contragent]).not_to be_nil
  end

  it "должна проверять наличие id задачи" do
    test_one.task_kind_id = nil
    expect(test_one).not_to be_valid
    expect(test_one.errors[:task_kind]).not_to be_nil
  end

  it "должна проверять корректность id задачи" do
    test_one.task_kind_id = 999 # несуществующий ID задачи
    expect(test_one).not_to be_valid
    expect(test_one.errors[:task_kind]).not_to be_nil
  end

  it "должна проверять корректность id статуса" do
    test_one.status_id = 999 # несуществующий ID статуса
    expect(test_one).not_to be_valid
    expect(test_one.errors[:status]).not_to be_nil
  end

  it "должна возвращать корректный набор данных :basement" do
    data = test_one.basement
    expect(data[:id]).to eq 1
    expect(data[:contragent]).to eq test_one.contragent.item
    expect(data[:task_kind]).to eq test_one.task_kind.item
    expect(data[:status]).to eq test_one.status.item
    expect(data[:revision]).to eq test_one.revision.basement
    expect(data[:cost]).to eq "70800.04"
    expect(data[:deadline_kind]).to eq "working_days"
    expect(data[:governmental]).to eq false
    expect(data[:signed_at]).to be_nil
  end

  it "должна возвращать корректный набор данных :card" do
    data = test_one.card
    #puts data.to_json
    expect(data[:id]).to eq 1
    expect(data[:head]).to eq "01-23-01"
    expect(data[:status]).to eq test_one.status.item
    expect(data[:task_kind]).to eq test_one.task_kind.item
    expect(data[:contragent]).to eq test_one.contragent.item
    expect(data[:code]).to eq "01"
    expect(data[:cost]).to eq "70800.04"
    expect(data[:stages].size).to eq 1
    expect(data[:stages][0]).to eq test_one.stages[0].basement
    expect(data[:revisions].size).to eq 1
    expect(data[:revisions][0]).to eq test_one.revisions[0].item
    expect(data[:revision]).to eq test_one.revision.basement
    expect(data[:deadline_kind]).to eq "working_days"
    expect(data[:governmental]).to eq false
    expect(data[:signed_at]).to be_nil
    expect(data[:summary]).not_to be_nil
  end
end
