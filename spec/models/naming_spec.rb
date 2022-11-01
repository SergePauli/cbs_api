require "rails_helper"

RSpec.describe Naming, type: :model do
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

  it "should be 4" do
    expect(Naming.count).to eq 4
  end

  it "clears namings" do
    #namings(:admin).destroy
    #expect { namings(:admin).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
