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
  scope "auth", controller: "auth/authentication" do
    post "/login", action: "login"
    get "/logout", action: "logout"
    get "/refresh", action: "refresh"
  end
  # Универсальный контроллер
  scope "model/:model_name", controller: "model/universal" do
    post "/", action: "index"
    post "/add", action: "create"
    get "/", action: "show"
    put "/:id", action: "update"
    delete "/:id", action: "destroy"
  end
end
