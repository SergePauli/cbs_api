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

  fixtures :contracts

  let (:test_one) {
    contracts(:krabcom_01_23_01)
  }
  it "должна возвращать корректный набор данных :card" do
    data = test_one.card
    puts data.to_json
    expect(data[:id]).to eq 1
    expect(data[:head]).to eq "01-23-01"
    expect(data[:status][:id]).to eq 1
    expect(data[:status][:name]).to eq "Согласование"
    expect(data[:status][:description]).to be_nil
    expect(data[:task_kind][:id]).to eq 2
    expect(data[:task_kind][:name]).to eq "Оценка эффективности"
    expect(data[:task_kind][:code]).to eq "01"
    expect(data[:cost]).to eq "70800.04"
    # expect(data[:stage_orders].size).to eq 1
    # expect(data[:performers].size).to eq 2
    # expect(data[:payments].size).to eq 2
    # expect(data[:duration]).to eq "30РДней"
    # expect(data[:deadline_kind]).to eq "working_days"
    # expect(data[:funded_at]).to be_nil
    # expect(data[:deadline_at]).to eq Date.parse("2023-03-01")
    # expect(data[:invoice_at]).to eq Date.parse("2023-01-27")
    # expect(data[:ride_out_at]).to eq Date.parse("2023-03-01")
    # expect(data[:is_ride_out]).to eq true
    # expect(data[:completed_at]).to be_nil
    # expect(data[:sended_at]).to be_nil
    # expect(data[:is_sended_at]).to be_nil
    # expect(data[:list_key]).to eq "7c69f63a-87f6-431d-9c5a-12df1004a499"
    expect(data[:summary]).not_to be_nil
  end
end
