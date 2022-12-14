require "rails_helper"

RSpec.describe SiteUrl, type: :model do

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  fixtures :contacts

  it "should be 1" do
    expect(SiteUrl.count).to eq 1
  end
  it "should check site URL format" do
    @contact = contacts(:cbs_site)
    expect(@contact).to be_valid
    @contact.value = "test"
    expect(@contact).not_to be_valid
    expect(@contact.errors[:value]).not_to be_nil
  end
end
