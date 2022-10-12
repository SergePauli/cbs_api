require "rails_helper"

RSpec.describe Area, type: :model do
  fixtures :areas

  before(:each) do
    @area = Area.new
  end

  it "should require name" do
    @area.name = nil
    expect(@area).not_to be_valid
    expect(@area.errors[:name]).not_to be_nil
  end

  it "should be uniqueness" do
    @area.name = areas(:city).name
    expect(@area).not_to be_valid
    expect(@area.errors[:name]).not_to be_nil
  end

  it "should be 2" do
    expect(Area.count).to eq 2
  end

  it "clears person_names" do
    areas(:city).destroy
    expect { areas(:city).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
