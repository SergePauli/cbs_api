class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.from_mail
  layout "mailer"

  #отправка письма с запросом активации на почту администратора приложения
  def confirmation_mail
    @user = User.find(params[:user_id])
    if @user
      @name = @user.head
      @email = @user.email
      @app_name = Rails.configuration.app_name
      @url = "http://#{Rails.configuration.base_url}/auth/activate/#{@user.activation_link}"
      mail(to: Rails.configuration.admin_mail, subject: "Запрос на активацию аккаунта")
    else
      raise "Exception in ApplicationMailer.confirmation_mail: invalid user_id '#{params[:user_id]}'"
    end
  end

  #отправка письма с уведомлением об активации
  def welcome_mail
    @email = params[:email]
    @app_name = Rails.configuration.app_name
    mail(to: params[:to], subject: "Аккаунт был активирован")
  end

  #отправка письма со ссылкой на смену пароля
  def pass_renew_mail
    @email = params[:email]
    @url = "http://#{Rails.configuration.client_url}/pass_renew/#{params[:link]}"
    mail(to: @email, subject: "Запрос на смену пароля")
  end
end
