require "rails_helper"

RSpec.describe Position, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  fixtures :positions

  before(:each) do
    @position = positions(:economist)
  end

  it "should be valid if valid" do
    expect(@position).to be_valid
  end

  it "should require name" do
    @position.name = nil
    expect(@position).not_to be_valid
    expect(@position.errors[:name]).not_to be_nil
  end

  it "should be uniqueness" do
    @new_position = Position.new
    @new_position.name = positions(:boss_ozi).name
    expect(@new_position).not_to be_valid
    expect(@new_position.errors[:name]).not_to be_nil
  end

  it "should be valided def_statuses" do
    expect(@position).to be_valid
    @position.def_statuses = "r,3,4"
    expect(@position).not_to be_valid
    expect(@position.errors[:def_statuses]).not_to be_nil
  end

  it "should be valided def_contracts_types" do
    expect(@position).to be_valid
    @position.def_contracts_types = "233,34,44"
    expect(@position).not_to be_valid
    expect(@position.errors[:def_contracts_types]).not_to be_nil
  end
end
