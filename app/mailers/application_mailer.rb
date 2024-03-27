class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.from_mail
  layout "mailer"

  #отправка письма с запросом активации на почту администратора приложения
  def confirmation_mail
    @user = User.find(params[:user_id])
    if @user
      @login = @user.name
      @name = @user.person.person_name.naming.head
      @email = @user.email
      @position = @user.position.name
      @department = @user.department.name
      @app_name = Rails.configuration.app_name
      @url = "#{Rails.configuration.base_url}/auth/activation/#{@user.activation_link}"
      mail(to: Rails.configuration.admin_mail, subject: "Запрос на активацию аккаунта")
    else
      raise "Exception in ApplicationMailer.confirmation_mail: invalid user_id '#{params[:user_id]}'"
    end
  end

  #отправка письма с уведомлением об активации
  def welcome_mail
    @email = params[:email]
    @app_name = Rails.configuration.app_name
    mail(to: params[:to], copy: Rails.configuration.admin_mail, subject: "Аккаунт был активирован")
  end

  #отправка письма со ссылкой на смену пароля
  def pass_renew_mail
    @name = params[:name]
    @url = "http://#{Rails.configuration.client_url}/pass_renew/#{params[:link]}"
    mail(to: params[:to], subject: "Запрос на смену пароля")
  end
end
