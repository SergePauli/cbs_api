require "rails_helper"

RSpec.describe "Auth::Registrations", type: :request do
  fixtures :departments, :users, :positions
  let (:test_user) { users(:user) }
  let (:headers) { { "ACCEPT" => "application/json" } }

  it "При неверных параметрах, экшин /auth/registration должен возвращать :unprocessable_entity и ошибки" do
    post "/auth/registration", params: { profile: { user: nil, position: nil } }, headers: headers
    expect(response.content_type).to eq("application/json; charset=utf-8")
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Не присвоена ДОЛЖНОСТЬ")
    expect(response.body).to include("Не присвоен ПОЛЬЗОВАТЕЛЬ")
  end

  it "При верных параметрах, экшин /auth/registration должен создавать профиль пользователя, возвращая статус :ok" do
    post "/auth/registration", params: { profile: { department_id: 1, list_key: SecureRandom.uuid, position_attributes: { name: "тестировщик" }, user_attributes: { name: "tester", password: "sfd4rwetcvgfdg", password_confirmation: "sfd4rwetcvgfdg", person_attributes: { person_contacts_attributes: [{ contact_attributes: { value: "test@mail.ru", type: "Email" }, used: true, list_key: SecureRandom.uuid }], person_names_attributes: [{ used: true, list_key: SecureRandom.uuid, naming_attributes: { name: "Апалон", surname: "Аполонов", patrname: "Григорьевич" } }] } } } }, headers: headers
    expect(response).to have_http_status(:ok)
    @profile = Profile.includes(:position).where(position: { name: "тестировщик" }).first
    @user = @profile.user
    expect(@user).not_to be_nil
    expect(@user.email).to eq "test@mail.ru"
    expect(@user.head).to eq "tester Аполонов А.Г. test@mail.ru"
  end

  it "При верном параметре 'link', экшин /auth/activation должен активировать, редиректить, и менять код активации пользователя" do
    @link = test_user.activation_link
    get "/auth/activation/#{@link}"
    expect(response).to redirect_to("http://#{Rails.configuration.client_url}/message/Аккаунт успешно активирован")
    @user = User.find(test_user.id)
    expect(@user.activated).to eq true
    expect(@user.activation_link).not_to eq @link
  end

  it "При неверном параметре 'link', экшин /auth/activation должен редиректить на cтраничку фронтэнда: Ссылка не действительна" do
    get "/auth/activation/invalid_link"
    expect(response).to redirect_to("http://#{Rails.configuration.client_url}/message/Ссылка не действительна")
  end

  it "При верном параметре 'name', экшин /auth/renew_link должен вернуть статус OK" do
    @name = test_user.name
    get "/auth/renew_link/#{@name}"
    expect(response).to have_http_status(:ok)
  end

  it "При неверном параметре 'name', экшин /auth/renew_link должен вернуть статус :not_acceptable" do
    get "/auth/renew_link/invalid_code"
    expect(response).to have_http_status(:not_acceptable)
  end

  it "При верных параметрах, экшин /auth/pwd_renew должен изменить пароль и код активации пользователя, возвращая статус :ok" do
    @activation_link = test_user.activation_link
    post "/auth/pwd_renew", params: { user: { activation_link: @activation_link, password: "new_pwd", password_confirmation: "new_pwd" } }, headers: headers
    expect(response).to have_http_status(:ok)
    @user = User.find(test_user.id)
    expect(@user.activation_link).not_to eq @activation_link
    expect(@user.authenticate("new_pwd")).not_to eq false
  end
  it "При несуществующем коде активации, экшин /auth/pwd_renew должен возвращать статус :not_acceptable" do
    post "/auth/pwd_renew", params: { user: { activation_link: "invalid_code", password: "new_pwd", password_confirmation: "new_pwd" } }, headers: headers
    expect(response).to have_http_status(:not_acceptable)
  end

  it "Экшин /auth/departments должен вернуть список отделов и статус OK" do
    get "/auth/departments"
    #puts response.body
    expect(response.body).to eq '[{"id":1,"name":"ОЗИ"},{"id":2,"name":"Коммерческий"},{"id":3,"name":"Бухгалтерия"},{"id":4,"name":"Руководство"},{"id":5,"name":"ИЛЦ"},{"id":6,"name":"ОПС"}]'
    expect(response).to have_http_status(:ok)
  end

  it "При пустых параметрах, экшин /auth/position должен вернуть список первых 25 должностей и статус :ok" do
    post "/auth/positions", headers: headers
    expect(response.body).to eq '[{"id":1,"name":"начальник отдела ОЗИ"},{"id":2,"name":"специалист"},{"id":3,"name":"экономист"},{"id":4,"name":"инженер-программист"},{"id":5,"name":"безопасник"}]'
    expect(response).to have_http_status(:ok)
  end

  it "При поиске <ист>, со позиции 2 и лимите в з записи экшин /auth/position должен вернуть определенный спискок и статус :ok" do
    post "/auth/positions", params: { q: { name_cont: "ист" }, offset: 1, limit: 1 }, headers: headers
    expect(response.body).to eq '[{"id":3,"name":"экономист"}]'
    expect(response).to have_http_status(:ok)
  end
end
