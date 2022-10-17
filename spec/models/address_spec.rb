require "rails_helper"

RSpec.describe Address, type: :model do
  fixtures :addresses

  before(:each) do
    @address = Address.new
  end

  it "should require area" do
    @address.value = addresses(:one).value
    expect(@address).not_to be_valid
    expect(@address.errors[:area]).not_to be_nil
  end

  it "should require value" do
    @address.area = addresses(:one).area
    @address.value = nil
    expect(@address).not_to be_valid
    expect(@address.errors[:value]).not_to be_nil
  end

  it "should be recognized invalid format of value" do
    @address = addresses(:invalid_value)
    expect(@address).not_to be_valid
    expect(@address.errors[:value]).not_to be_nil
  end

  it "should be recognized [пер.]" do
    @address = addresses(:moscow_1)
    expect(@address).to be_valid
  end

  it "should be recognized [переулок.]" do
    @address = addresses(:moscow_2)
    expect(@address).to be_valid
  end

  it "should be recognized [набережная.]" do
    @address = addresses(:moscow_3)
    expect(@address).to be_valid
  end

  it "should be recognized [аллея.]" do
    @address = addresses(:moscow_4)
    expect(@address).to be_valid
  end

  it "should be recognized [бул.]" do
    @address = addresses(:moscow_5)
    expect(@address).to be_valid
  end

  it "should be recognized [бульвар.]" do
    @address = addresses(:moscow_6)
    expect(@address).to be_valid
  end

  it "should be recognized [проезд.]" do
    @address = addresses(:moscow_7)
    expect(@address).to be_valid
  end

  it "should be recognized [кольцо.]" do
    @address = addresses(:moscow_8)
    expect(@address).to be_valid
  end

  it "should be 10" do
    expect(Address.count).to eq 10
  end

  it "clear Addresses" do
    addresses(:moscow_4).destroy
    expect { addresses(:moscow_4).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
