require "rails_helper"

RSpec.describe Contact, type: :model do
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
end
