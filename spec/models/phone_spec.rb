require "rails_helper"

RSpec.describe Phone, type: :model do

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  fixtures :contacts

  it "should be 4" do
    expect(Phone.count).to eq 4
  end

  it "should check phonenumber" do
    @contact = contacts(:cbs_phone)
    expect(@contact).not_to be_valid
    expect(@contact.errors[:value]).not_to be_nil
    @contact = contacts(:cbs_mobile)
    expect(@contact).to be_valid
    @contact.value = "89271234567"
    expect(@contact).to be_valid
    @contact.value = "+7 84457 123 45"
    expect(@contact).to be_valid
    @contact.value = "+7(999)000-00-00"
    expect(@contact).to be_valid
  end
end
