require "rails_helper"

RSpec.describe Email, type: :model do
  fixtures :contacts

  it "should be 4" do
    expect(Email.count).to eq 4
  end

  it "should check email format" do
    @contact = contacts(:cbs_mail)
    expect(@contact).to be_valid
    @contact.value = "test"
    expect(@contact).not_to be_valid
    expect(@contact.errors[:value]).not_to be_nil
  end
end
