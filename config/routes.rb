Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # Авторизация
  scope "auth", controller: "auth/registration" do
    post "/registration", action: "registration"
    get "/activation/:link", action: "activation"
  end
end
