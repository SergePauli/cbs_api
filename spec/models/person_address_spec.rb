require "rails_helper"

RSpec.describe PersonAddress, type: :model do
  fixtures :person_addresses

  before(:each) do
    @person_address = PersonAddress.new
  end

  it "should require person" do
    @person_address.address_id = person_addresses(:admin).address_id
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:person]).not_to be_nil
    @person_address.person_id = 899 # this person ID not exist
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:person]).not_to be_nil
  end

  it "should require address" do
    @person_address.person_id = person_addresses(:admin).person_id
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:address]).not_to be_nil
    @person_address.address_id = 899 # this address ID not exist
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:address]).not_to be_nil
  end

  it "should be uniq" do
    @person_address.person_id = person_addresses(:admin).person_id
    @person_address.address_id = person_addresses(:admin).address_id
    expect(@person_address).not_to be_valid
    expect(@person_address.errors[:address]).not_to be_nil # "has already been taken"
    expect(@person_address.errors[:person]).not_to be_nil # "has already been taken"
  end
end
