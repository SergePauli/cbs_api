require "rails_helper"

RSpec.describe PersonName, type: :model do
  fixtures :person_names

  before(:each) do
    @person_name = PersonName.new
  end

  it "should require person" do
    @person_name.naming_id = person_names(:admin).naming_id
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:person]).not_to be_nil
    @person_name.person_id = 899 # this person ID not exist
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:person]).not_to be_nil
  end

  it "should require naming" do
    @person_name.person_id = person_names(:admin).person_id
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:naming]).not_to be_nil
    @person_name.naming_id = 899 # this naming ID not exist
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:naming]).not_to be_nil
  end

  it "should be uniq" do
    @person_name.person_id = person_names(:admin).person_id
    @person_name.naming_id = person_names(:admin).naming_id
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:naming]).not_to be_nil # "has already been taken"
    expect(@person_name.errors[:person]).not_to be_nil # "has already been taken"
  end
end
