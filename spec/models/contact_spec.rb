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

  it "should be 5" do
    expect(Contact.count).to eq 6
  end

  it "clears contacts" do
    contacts(:cbs_mail).destroy
    expect { contacts(:cbs_mail).reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
