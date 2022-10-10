require "rails_helper"

RSpec.describe Telegram, type: :model do
  fixtures :contacts
  it "should be 1" do
    expect(Telegram.count).to eq 1
  end
  it "should check nikname" do
    @contact = contacts(:cbs_telegram)
    expect(@contact).to be_valid
    @contact.value = "test"
    expect(@contact).not_to be_valid
    expect(@contact.errors[:value]).not_to be_nil
  end
end
