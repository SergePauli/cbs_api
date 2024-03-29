require "rails_helper"

RSpec.describe PersonName, type: :model do
  # поддерживает правило одной используемой записи
  it_behaves_like "singleable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData и Singleable
  it { is_expected.to respond_to(:state, :used, :main_model_id) }

  fixtures :person_names, :namings, :people

  before(:each) do
    @person_name = PersonName.new
    @person_name.list_key = SecureRandom.uuid
  end

  it "should require person" do
    @person_name.naming_id = person_names(:admin).naming_id
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:person]).not_to be_nil
    @person_name.person_id = 899 # this person ID not exist
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:person]).not_to be_nil
  end

  it "should require naming" do
    @person_name.person_id = person_names(:admin).person_id
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:naming]).not_to be_nil
    @person_name.naming_id = 899 # this naming ID not exist
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:naming]).not_to be_nil
  end

  it "should be uniq" do
    @person_name.person_id = person_names(:admin).person_id
    @person_name.naming_id = person_names(:admin).naming_id
    expect(@person_name).not_to be_valid
    expect(@person_name.errors[:naming]).not_to be_nil # "has already been taken"
    expect(@person_name.errors[:person]).not_to be_nil # "has already been taken"
  end

  it "should not to be create dublicates of naming" do
    @person_name.person_id = person_names(:admin).person_id
    @person_name.naming = Naming.new
    @person_name.naming.name = namings(:client).name
    @person_name.naming.surname = namings(:client).surname
    @person_name.used = false
    expect(@person_name).to be_valid
  end

  it "должна создаваться запись c nested attributes" do
    @person_name = PersonName.new({ person_id: 1, used: false, naming_attributes: { name: "Апалон", surname: "Аполонов", patrname: "Григорьевич" }, list_key: SecureRandom.uuid })
    @person_name.save
    expect(@person_name).not_to be_nil
    expect(@person_name).to be_valid
  end
end
