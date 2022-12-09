Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Регистрация, пароли
  scope "auth", controller: "auth/registration" do
    post "/registration", action: "registration"
    get "/activation/:link", action: "activation"
    get "/renew_link/:name", action: "renew_link"
    post "/pwd_renew", action: "pwd_renew"
  end
  # Авторизация
end
