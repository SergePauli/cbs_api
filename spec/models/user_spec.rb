require "rails_helper"

RSpec.describe User, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # добавленные методы
  it { is_expected.to respond_to(:email) }

  fixtures :users

  it "константы ролей пользователя должны быть определены" do
    expect(User::ADMIN).to eq "admin"
    expect(User::USER).to eq "user"
    expect(User::ROLES).to eq ["admin", "user"]
  end

  before(:each) do
    @user = users(:admin)
  end

  it "валидация должна быть успешной при отсутствии ошибок" do
    expect(@user).to be_valid
  end
end
