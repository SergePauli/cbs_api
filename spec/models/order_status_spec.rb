require "rails_helper"

RSpec.describe OrderStatus, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # обеспечение Named
  it { is_expected.to have_db_column(:name).of_type(:string) }
  # обеспечение порядка появления статусов
  it { is_expected.to have_db_column(:order).of_type(:integer) }

  it { is_expected.to have_db_column(:description).of_type(:string) }

  let (:new_order_status) {
    OrderStatus.new
  }

  it "должно проверяться наличие :name" do
    new_order_status.name = nil
    expect(new_order_status).not_to be_valid
    expect(new_order_status.errors[:name]).not_to be_nil
  end

  fixtures :order_statuses
  it "должна проверяться уникальность :name" do
    new_order_status.name = order_statuses(:asked).name
    expect(new_order_status).not_to be_valid
    expect(new_order_status.errors[:name]).not_to be_nil
  end

  let (:status) {
    OrderStatus.new(name: "новый статус", order: 9, description: "новый тестовый статус")
  }

  it "должна быть валидной в случае штатных параметров" do
    expect(status).to be_valid
  end

  it "должна штатно сздаваться (c запоминанием :name, :description, :order), удаляться" do
    expect(status.save).to eq true
    expect(status.id).not_to be_nil
    expect(status.head).to eq "новый статус"
    expect(status.item[:description]).to eq "новый тестовый статус"
    expect(OrderStatus.count).to eq 4
    status.destroy
    expect(OrderStatus.count).to eq 3
  end

  it "набор :item должен содержать :id, :name, :description" do
    status.save
    data = status.item
    expect(data[:id]).not_to be_nil
    expect(data[:name]).to eq "новый статус"
    expect(data[:description]).to eq "новый тестовый статус"
  end

  it "набор :card должен содержать :id, :name, :description, :order и время создания" do
    status.save
    data = status.card
    expect(data[:id]).not_to be_nil
    expect(data[:head]).to eq "новый статус"
    expect(data[:description]).to eq "новый тестовый статус"
    expect(data[:order]).to eq 9
    expect(data[:summary][:created]).not_to be_nil
  end
end
