require "rails_helper"

RSpec.describe User, type: :model do
  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }

  # для NamedRecord
  it { is_expected.to respond_to(:name) }

  # реализовано в модели
  it { is_expected.to respond_to(:password_digest, :person, :last_login, :role, :activation_link, :activated, :new_activation_link) }

  # добавленные методы
  it { is_expected.to respond_to(:email) }

  fixtures :users

  it "константы ролей пользователя должны быть определены" do
    expect(User::ADMIN).to eq "admin"
    expect(User::USER).to eq "user"
    expect(User::ROLES).to eq ["admin", "user"]
  end

  it "должна генерироваться ссылка на активацию при создании экземпляра" do
    @user = User.new
    expect(@user.activation_link).not_to be_nil
    expect(@user.activation_link.size).to eq 34
    expect(@user.activated).to eq false
  end

  before(:each) do
    @user = users(:admin)
  end

  it "валидация должна быть успешной при отсутствии ошибок" do
    expect(@user).to be_valid
  end

  it "валидация не должна быть успешной при отсутствии или неверном name" do
    @user.name = nil
    expect(@user).not_to be_valid
    @user.name = "inncorect login"
    expect(@user).not_to be_valid
    @user.name = "inc*rrect_l*gin"
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

  it "метод Head должен возвращать имя пользователя и заголовок его персональных данных" do
    expect(@user.head).to eq "#{@user.name} #{@user.person.head}"
  end

  it "метод Card должен возвращать роли пользователя" do
    expect(@user.card[:role]).to eq @user.role
  end

  it "метод Card должен возвращать последний вход в систему" do
    expect(@user.card[:last_login]).to eq @user.last_login
  end

  it "метод Card должен возвращать card персоны" do
    expect(@user.card[:person]).to eq @user.person.card
  end
end
