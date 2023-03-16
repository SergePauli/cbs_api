require "rails_helper"

RSpec.describe ContragentOrganization, type: :model do
  # поддерживает правило одной используемой записи
  it_behaves_like "singleable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData и Singleable
  it { is_expected.to respond_to(:state, :used, :main_model_id) }

  fixtures :contragents, :contragent_organizations, :organizations

  before(:each) do
    @contragent_organization = ContragentOrganization.new
    @contragent_organization.list_key = SecureRandom.uuid
  end

  it "Должна быть невалидной c невалидным id контрагента" do
    @contragent_organization.organization_id = organizations(:kraskom).id
    expect(@contragent_organization).not_to be_valid
    expect(@contragent_organization.errors[:contragent]).not_to be_nil
    @contragent_organization.contragent_id = 899 # this contragent ID not exist
    expect(@contragent_organization).not_to be_valid
    expect(@contragent_organization.errors[:contragent]).not_to be_nil
  end

  it "Должна быть невалидной с невалидным id организации" do
    @contragent_organization.contragent_id = contragents(:kraskom).id
    expect(@contragent_organization).not_to be_valid
    expect(@contragent_organization.errors[:organization]).not_to be_nil
    @contragent_organization.organization_id = 899 # this  organization ID not exist
    expect(@contragent_organization).not_to be_valid
    expect(@contragent_organization.errors[:organization]).not_to be_nil
  end

  it "должна быть уникальной комбинация id организации и контрагента" do
    @contragent_organization.contragent_id = contragents(:kraskom).id
    @contragent_organization.organization_id = organizations(:kraskom).id
    expect(@contragent_organization).not_to be_valid
    expect(@contragent_organization.errors[:organization]).not_to be_nil # "has already been taken"
    expect(@contragent_organization.errors[:contragent]).not_to be_nil # "has already been taken"
  end

  it "Не должено создаваться дублирующих организаций" do
    @contragent_organization.contragent_id = contragents(:med_rzd).id
    @contragent_organization.organization = Organization.new
    @contragent_organization.organization.name = organizations(:kraskom).name

    @contragent_organization.used = false
    expect(@contragent_organization).not_to be_valid
  end

  it "должна создаваться запись c nested attributes" do
    @contragent_organization = ContragentOrganization.new({ contragent_id: 1, used: false, organization_attributes: { name: "ООО 'Рога и копыта'", full_name: "Тестовая организация", ownership_id: 1, inn: "2466114217" }, list_key: SecureRandom.uuid })
    @contragent_organization.save
    expect(@contragent_organization).not_to be_nil
    expect(@contragent_organization).to be_valid
  end
end
