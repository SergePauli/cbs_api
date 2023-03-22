require "rails_helper"

RSpec.describe Payment, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  it { is_expected.to have_db_column(:list_key).of_type(:uuid) }
  it { is_expected.to have_db_column(:stage_id).of_type(:integer) }
  it { is_expected.to have_db_column(:payment_kind).of_type(:integer) }
  it { is_expected.to have_db_column(:payment_at).of_type(:date) }
  it { is_expected.to have_db_column(:description).of_type(:string) }

  fixtures :stages, :payments

  let (:new_payment) {
    Payment.new({ stage_id: stages(:krabcom_01_23_01).id, payment_kind: :prepayment, payment_at: Date.parse("2023-03-13"), list_key: "38fdfe7e-6eec-4ec4-bbf0-aa1b8500f3f5" })
  }

  it "Должна быть невалидной c невалидным id этапа" do
    expect(new_payment.errors[:stage]).not_to be_nil
    new_payment.stage_id = 899 # несуществующий ID этапа
    expect(new_payment).not_to be_valid
    expect(new_payment.errors[:stage]).not_to be_nil
    #puts new_payment.errors.to_json
  end

  it "Должна быть невалидной c невалидным типом платежа" do
    expect { new_payment.payment_kind = :invalid_kind }.to raise_error(ArgumentError)
                                                             .with_message(/'invalid_kind' is not a valid payment_kind/)
  end

  it "должна штатно создаваться и обновляться (c запоминанием :stage_id, :payment_kind, :description, :payment_at), удаляться" do
    expect(new_payment.save).to eq true
    #puts new_payment.errors.to_json
    expect(new_payment.id).not_to be_nil
    expect(new_payment.head).to eq "13.03.2023-предоплата"
    new_payment.description = "новый тестовый платеж"
    expect(new_payment.save).to eq true
    expect(new_payment.card[:description]).to eq "новый тестовый платеж"
    expect(Payment.count).to eq 3
    new_payment.destroy
    expect(Payment.count).to eq 2
  end

  it "должна возвращать коректный :name" do
    expect(payments(:last_payment).name).to eq "03.03.2023-оплата"
  end

  it "должна возвращать коректный набор данных :item" do
    data = payments(:last_payment).item
    expect(data[:id]).to eq 2
    expect(data[:name]).to eq "03.03.2023-оплата"
  end

  it "должна возвращать коректный набор данных :card" do
    data = payments(:last_payment).card
    expect(data[:id]).to eq 2
    expect(data[:head]).to include("03.03.2023-оплата")
    expect(data[:stage][:id]).to eq 1
    expect(data[:stage][:name]).to eq "Оценка эффективности"
    expect(data[:stage][:priority]).to eq 0
    expect(data[:payment_kind]).to eq "last_payment"
    expect(data[:payment_at]).to eq Date.parse("2023-03-03")
    expect(data[:description]).to match "оплата"

    expect(data[:summary]).not_to be_nil
    expect(data[:list_key]).not_to be_nil
  end
end
