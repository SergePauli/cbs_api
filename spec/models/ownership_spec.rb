require "rails_helper"

RSpec.describe Ownership, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  fixtures :ownerships

  before(:each) do
    @ownership = Ownership.new
  end

  it "should require name" do
    @ownership.name = nil
    expect(@ownership).not_to be_valid
    expect(@ownership.errors[:name]).not_to be_nil
  end

  it "should be uniqueness" do
    @ownership.name = ownerships(:ooo).name
    expect(@ownership).not_to be_valid
    expect(@ownership.errors[:name]).not_to be_nil
  end

  it "clears" do
    ownerships(:oao).destroy
    expect { ownerships(:oao).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "should return default custom_data :head" do
    expect(ownerships(:ooo).custom_data :head).to eq ownerships(:ooo).name
  end

  it "should return default custom_data :item" do
    data = ownerships(:ooo).custom_data :item
    expect(data[:name]).to eq ownerships(:ooo).name
    expect(data[:id]).to eq ownerships(:ooo).id
    expect(data[:created_at]).to be_nil
  end

  it "should return default custom_data :summary" do
    data = ownerships(:ooo).custom_data :summary
    expect(data[:created].to_formatted_s(:short)).to eq ownerships(:ooo).created_at.to_formatted_s(:short)
    expect(data[:updated].to_formatted_s(:short)).to eq ownerships(:ooo).updated_at.to_formatted_s(:short)
    expect(data[:id]).to be_nil
  end

  it "should return default custom_data :card" do
    data = ownerships(:ooo).custom_data :card
    expect(data[:summary][:created].to_formatted_s(:short)).to eq ownerships(:ooo).created_at.to_formatted_s(:short)
    expect(data[:summary][:updated].to_formatted_s(:short)).to eq ownerships(:ooo).updated_at.to_formatted_s(:short)
    expect(data[:id]).to eq ownerships(:ooo).id
    expect(data[:head]).to eq ownerships(:ooo).name
  end

  it "should return false for custom_data :none" do
    expect(ownerships(:ooo).custom_data :none).to eq false
  end
end
