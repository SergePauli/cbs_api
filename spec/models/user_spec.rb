require "rails_helper"

RSpec.describe User, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для NamedRecord
  it { is_expected.to respond_to(:name) }

  # реализовано в модели
  it { is_expected.to respond_to(:password_digest, :person, :last_login, :role) }

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

  it "валидация не должна быть успешной при отсутствии name" do
    @user.name = nil
    expect(@user).not_to be_valid
    expect(@user.errors[:name]).not_to be_nil
  end

  it "валидация не должна быть успешной если name уже занято" do
    @user.name = users(:user).name
    expect(@user).not_to be_valid
    expect(@user.errors[:name]).not_to be_nil
  end

  it "валидация не должна быть успешной при отсутствии person" do
    @user.person = nil
    expect(@user).not_to be_valid
    expect(@user.errors[:person]).not_to be_nil
  end

  it "валидация не должна быть успешной при отсутствии email" do
    @user.person = Person.new
    expect(@user).not_to be_valid
    expect(@user.errors[:email]).not_to be_nil
  end

  it "валидация не должна быть успешной при неверном role" do
    @user.role = "unknow,user"
    expect(@user).not_to be_valid
    @user.role = "unknow"
    expect(@user).not_to be_valid
    @user.role = "user admin"
    expect(@user).not_to be_valid
    @user.role = "user,admin"
    expect(@user).to be_valid
    expect(@user.errors[:email]).not_to be_nil
  end
end
