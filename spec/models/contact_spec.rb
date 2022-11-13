require "rails_helper"

RSpec.describe Contact, type: :model do

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  fixtures :contacts

  before(:each) do
    @contact = Contact.new
  end

  it "should require value" do
    @contact.value = nil
    expect(@contact).not_to be_valid
    expect(@contact.errors[:value]).not_to be_nil
  end

  it "should require type" do
    @contact.value = "test"
    @contact.type = nil
    expect(@contact).not_to be_valid
    expect(@contact.errors[:type]).not_to be_nil
  end

  it "should type inclusion" do
    @contact.value = "test"
    @contact.type = "invalid_type"
    expect(@contact).not_to be_valid
    expect(@contact.errors[:type]).not_to be_nil
  end

  it "should be 10" do
    expect(Contact.count).to eq 11
  end

  it "clears contacts" do
    contacts(:some_mail).destroy
    expect { contacts(:some_mail).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "should be unique" do
    @contact.value = contacts(:cbs_mail).value
    @contact.type = contacts(:cbs_mail).type
    expect(@contact).not_to be_valid
    expect(@contact.errors[:value]).not_to be_nil # "has already been taken"
    expect(@contact.errors[:type]).not_to be_nil # "has already been taken"
  end

  it "should return default custom_data :head" do
    expect(contacts(:cbs_mail).custom_data :head).to eq contacts(:cbs_mail).name
  end

  it "should return default custom_data :card" do
    data = contacts(:cbs_mail).custom_data :card
    expect(data[:type]).to eq contacts(:cbs_mail).type
  end
end
