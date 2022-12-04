require "rails_helper"

RSpec.describe "Auth::Registrations", type: :request do
  fixtures :departments, :users
  it "При неверных параметрах, экшин /auth/registration должен возвращать :unprocessable_entity и ошибки" do
    headers = { "ACCEPT" => "application/json" }
    post "/auth/registration", params: { profile: { user: nil, position: nil } }, headers: headers
    expect(response.content_type).to eq("application/json; charset=utf-8")
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Position must exist")
    expect(response.body).to include("User must exist")
  end

  it "При верных параметрах, экшин /auth/registration должен создавать профиль пользователя, возвращая статус :ok" do
    headers = { "ACCEPT" => "application/json" }
    post "/auth/registration", params: { profile: { department_id: 1, position_attributes: { name: "тестировщик" }, user_attributes: { name: "tester", password: "sfd4rwetcvgfdg", password_confirmation: "sfd4rwetcvgfdg", person_attributes: { person_contacts_attributes: [{ contact_attributes: { value: "test@mail.ru", type: "Email" }, used: true }], person_names_attributes: [{ used: true, naming_attributes: { name: "Апалон", surname: "Аполонов", patrname: "Григорьевич" } }] } } } }, headers: headers
    expect(response).to have_http_status(:ok)
    @profile = Profile.includes(:position).where(position: { name: "тестировщик" }).first
    @user = @profile.user
    expect(@user).not_to be_nil
    expect(@user.email).to eq "test@mail.ru"
    expect(@user.head).to eq "tester Аполонов А.Г. test@mail.ru"
  end

  it "При верном параметре 'link', экшин /auth/activation должен редиректить на cтраничку фронтэнда: Аккаунт успешно активирован" do
    @link = users(:user).activation_link
    get "/auth/activation/#{@link}"
    expect(response).to redirect_to("http://#{Rails.configuration.client_url}/message/Аккаунт успешно активирован")
    @user = User.where(activation_link: @link).first
    expect(@user.activated).to eq true
  end
  it "При неверном параметре 'link', экшин /auth/activation должен редиректить на cтраничку фронтэнда: Ссылка не действительна" do
    get "/auth/activation/invalid_link"
    expect(response).to redirect_to("http://#{Rails.configuration.client_url}/message/Ссылка не действительна")
  end
end
