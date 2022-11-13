require "rails_helper"

RSpec.describe Department, type: :model do

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  fixtures :departments

  before(:each) do
    @department = departments(:ILC)
  end

  it "should require name" do
    @department.name = nil
    expect(@department).not_to be_valid
    expect(@department.errors[:name]).not_to be_nil
  end

  it "should be uniqueness" do
    @new_department = Department.new
    @new_department.name = departments(:ILC).name
    expect(@new_department).not_to be_valid
    expect(@new_department.errors[:name]).not_to be_nil
  end

  it "should be valided def_statuses" do
    expect(@department).to be_valid
    @department.def_statuses = "r,3,4"
    expect(@department).not_to be_valid
    expect(@department.errors[:def_statuses]).not_to be_nil
  end

  it "should be valided def_contract_types" do
    expect(@department).to be_valid
    @department.def_contract_types = "233,34,44"
    expect(@department).not_to be_valid
    expect(@department.errors[:def_contract_types]).not_to be_nil
  end
end
