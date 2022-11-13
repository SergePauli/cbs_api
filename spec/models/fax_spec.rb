require "rails_helper"

RSpec.describe Fax, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  fixtures :contacts
  it "should be 1" do
    expect(Fax.count).to eq 1
  end
  it "should check phonenumber" do
    @contact = contacts(:cbs_fax)
    @contact.value = "test"
    expect(@contact).not_to be_valid
    expect(@contact.errors[:value]).not_to be_nil
    @contact.value = "89271234567"
    expect(@contact).to be_valid
    @contact.value = "+7 84457 123 45"
    expect(@contact).to be_valid
    @contact.value = "+7(999)000-00-00"
    expect(@contact).to be_valid
  end
end
