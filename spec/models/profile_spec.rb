require "rails_helper"

RSpec.describe Profile, type: :model do

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для совместимости с MutableData
  it { is_expected.to respond_to(:state, :used, :priority) }

  # реализовано в моделиs
  it { is_expected.to respond_to(:user, :position, :department, :statuses, :contracts_types) }

  fixtures :profiles, :positions, :departments

  before(:each) do
    @profile = profiles(:admin)
  end

  it "валидация должна быть успешной при отсутствии ошибок" do
    expect(@profile).to be_valid
    @profile = profiles(:user)
    expect(@profile).to be_valid
  end

  it "валидация не должна быть успешной при отсутствии user" do
    @profile.user = nil
    expect(@profile).not_to be_valid
    expect(@profile.errors[:user]).not_to be_nil
  end

  it "валидация не должна быть успешной при отсутствии position" do
    @profile.position = nil
    expect(@profile).not_to be_valid
    expect(@profile.errors[:position]).not_to be_nil
  end

  it "метод Head должен возвращать имена пользователя и его должности" do
    expect(@profile.head).to eq "#{@profile.user.name} #{@profile.position.name}"
  end

  it "метод Card должен возвращать item должности" do
    expect(@profile.card[:position]).to eq @profile.position.item
  end

  it "метод Card должен возвращать item отдела" do
    expect(@profile.card[:department]).to be_nil
    @profile = profiles(:user)
    expect(@profile.card[:department]).to eq @profile.department.item
  end

  it "метод Card должен возвращать item пользователя" do
    expect(@profile.card[:user]).to eq @profile.user.item
  end
end
