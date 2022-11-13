require "rails_helper"

RSpec.describe Naming, type: :model do

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  fixtures :namings

  before(:each) do
    @name = Naming.new
  end

  it "should require surname" do
    @name.surname = ""
    @name.name = "test"
    expect(@name).not_to be_valid
    expect(@name.errors[:surname]).not_to be_nil
    @name.surname = nil
    expect(@name).not_to be_valid
    expect(@name.errors[:surname]).not_to be_nil
  end

  it "should require name" do
    @name.surname = namings(:admin).surname
    @name.name = nil
    expect(@name).not_to be_valid
    expect(@name.errors[:name]).not_to be_nil
  end

  it "should be uniqueness" do
    @name.surname = namings(:admin).surname
    @name.name = namings(:admin).name
    @name.patrname = namings(:admin).patrname
    expect(@name).not_to be_valid
    expect(@name.errors[:surname]).not_to be_nil
  end

  it "should be 5" do
    expect(Naming.count).to eq 5
  end

  it "should return default custom_data :head" do
    expect(namings(:admin).custom_data :head).to eq "Тестов Тест Тестович"
    expect(namings(:client).custom_data :head).to eq "Иванов Иван"
  end

  it "clears namings" do
    namings(:unused).destroy
    expect { namings(:unused).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
