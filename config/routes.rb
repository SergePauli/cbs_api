Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Регистрация, пароли
  scope "auth", controller: "auth/registration" do
    post "/registration", action: "registration"
    get "/activation/:link", action: "activation"
    get "/renew_link/:name", action: "renew_link"
    post "/pwd_renew", action: "pwd_renew"
    get "/departments", action: "departments"
    post "/positions", action: "positions"
  end
  # Авторизация
  scope "auth", controller: "auth/authentication" do
    post "/login", action: "login"
    get "/logout", action: "logout"
    get "/refresh", action: "refresh"
    get "/commer", action: "commer"
  end
  # Универсальный контроллер
  scope "model", controller: "model/universal" do
    post "/:model_name", action: "index"
    post "/add/:model_name", action: "create"
    get "/:model_name", action: "show"
    put "/:model_name/:id", action: "update"
    delete "/:model_name/:id", action: "destroy"
  end

  # Профиль контроллер
  scope "profile", controller: "profile" do
    get "/activity/:profile_id", action: "activity"
    get "/contract/:contract_id", action: "contract"
  end
end
