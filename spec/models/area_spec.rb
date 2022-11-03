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

  it "should be 3" do
    expect(Area.count).to eq 3
  end

  it "clears person_names" do
    areas(:region).destroy
    expect { areas(:region).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "should return default custom_data :head" do
    expect(areas(:city).custom_data :head).to eq areas(:city).name
  end

  it "should return default custom_data :item" do
    data = areas(:city).custom_data :item
    expect(data[:name]).to eq areas(:city).name
    expect(data[:id]).to eq areas(:city).id
    expect(data[:created_at]).to be_nil
  end

  it "should return default custom_data :summary" do
    data = areas(:city).custom_data :summary
    expect(data[:created].to_formatted_s(:short)).to eq areas(:city).created_at.to_formatted_s(:short)
    expect(data[:updated].to_formatted_s(:short)).to eq areas(:city).updated_at.to_formatted_s(:short)
    expect(data[:id]).to be_nil
  end

  it "should return default custom_data :card" do
    data = areas(:city).custom_data :card
    expect(data[:summary][:created].to_formatted_s(:short)).to eq areas(:city).created_at.to_formatted_s(:short)
    expect(data[:summary][:updated].to_formatted_s(:short)).to eq areas(:city).updated_at.to_formatted_s(:short)
    expect(data[:id]).to eq areas(:city).id
    expect(data[:head]).to eq areas(:city).name
  end

  it "should return false for custom_data :none" do
    expect(areas(:city).custom_data :none).to eq false
  end
end
