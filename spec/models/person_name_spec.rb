require "rails_helper"

RSpec.describe PersonName, type: :model do
  fixtures :person_names

  before(:each) do
    @name = PersonName.new
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
    @name.surname = person_names(:admin).surname
    @name.name = nil
    expect(@name).not_to be_valid
    expect(@name.errors[:name]).not_to be_nil
  end

  it "should be uniqueness" do
    @name.surname = person_names(:admin).surname
    @name.name = person_names(:admin).name
    @name.patrname = person_names(:admin).patrname
    expect(@name).not_to be_valid
    expect(@name.errors[:surname]).not_to be_nil
  end

  it "should be 3" do
    expect(PersonName.count).to eq 3
  end

  it "clears person_names" do
    person_names(:admin).destroy
    expect { person_names(:admin).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
