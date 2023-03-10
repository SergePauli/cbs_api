require "rails_helper"

RSpec.describe IsecurityTool, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # обеспечение Named
  it { is_expected.to have_db_column(:name).of_type(:string) }
  # обеспечение порядка появления статусов
  it { is_expected.to have_db_column(:priority).of_type(:integer) }

  it { is_expected.to have_db_column(:unit).of_type(:string) }

  let (:new_IST) {
    IsecurityTool.new
  }

  it "должно проверяться наличие :name" do
    new_IST.name = nil
    expect(new_IST).not_to be_valid
    expect(new_IST.errors[:name]).not_to be_nil
  end

  fixtures :isecurity_tools
  it "должна проверяться уникальность :name" do
    new_IST.name = isecurity_tools(:d_l).name
    expect(new_IST).not_to be_valid
    expect(new_IST.errors[:name]).not_to be_nil
  end

  let (:i_s_t) {
    IsecurityTool.new(name: "новый СЗИ", priority: 1, unit: "ед.")
  }

  it "должна быть валидной в случае штатных параметров" do
    expect(i_s_t).to be_valid
  end

  it "должна штатно сздаваться (c запоминанием :name, :priority, :unit), удаляться" do
    expect(i_s_t.save).to eq true
    expect(i_s_t.id).not_to be_nil
    expect(i_s_t.head).to eq "новый СЗИ"
    expect(IsecurityTool.count).to eq 4
    i_s_t.destroy
    expect(IsecurityTool.count).to eq 3
  end

  it "набор :item должен содержать :id, :name" do
    i_s_t.save
    data = i_s_t.item
    expect(data[:id]).not_to be_nil
    expect(data[:name]).to eq "новый СЗИ"
  end

  it "набор :card должен содержать :id, :name, :priority, :unit и время создания" do
    i_s_t.save
    data = i_s_t.card
    expect(data[:id]).not_to be_nil
    expect(data[:head]).to eq "новый СЗИ"
    expect(data[:unit]).to eq "ед."
    expect(data[:priority]).to eq 1
    expect(data[:summary][:created]).not_to be_nil
  end
end
