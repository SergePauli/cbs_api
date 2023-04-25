class Auth::RegistrationController < ApplicationController

  # POST auth/registration
  # создает профиль пользователя с неактивированным аккаунтом,
  # посылает запрос администратору со ссылкой активации
  # принимает параметр :profile c полями из Profile.permitted_params
  def registration
    @profile = Profile.new(profile_params)
    if @profile.save
      ApplicationMailer.with(user_id: @profile.user_id).confirmation_mail.deliver_later
      render status: :ok
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET auth/activation/:link
  # активирует аккаунт пользователя и рассылает уведомления пользователю и администратору
  def activation
    @user = User.where(activation_link: params[:link]).first
    if @user && !@user.activated
      @user.activated = true
      @user.activation_link = User.new_activation_link #прежний код активации(восстановления) теперь не действителен - генерируем новый
      if @user.save
        ApplicationMailer.with(email: @user.email, to: @user.email).welcome_mail.deliver_later
        redirect_to "http://#{Rails.configuration.client_url}/message/Аккаунт успешно активирован"
      end
    elsif @user && @user.activated
      redirect_to "http://#{Rails.configuration.client_url}/message/Аккаунт был активирован ранее"
    else
      redirect_to "http://#{Rails.configuration.client_url}/message/Ссылка не действительна"
    end
  end

  # GET auth/renew_link/:name
  # отправляет ссылку для восстановления пароля на почту владельцу аккаунта
  # принимает параметр name - имя пользователя
  def renew_link
    get_user
    ApplicationMailer.with(name: @user.name, to: @user.email, link: @user.activation_link).pass_renew_mail.deliver_later
    render status: :ok
  end

  # POST auth/pwd_renew
  # изменяет пароль пользователя
  # принимает параметр :user с полями  :activation_link, :password, :password_confirmation
  def pwd_renew
    @user = User.where(activation_link: params[:user][:activation_link]).first
    raise ApiError.new("Неверный код", :not_acceptable) unless @user
    if @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation], activation_link: User.new_activation_link)
      render status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET auth/departments
  # отдает список отделов (для регистрации профиля пользователя)
  def departments
    @departments = Department.all
    result = []
    @departments.each { |department| result.push(department.item) }
    render json: result, status: :ok
  end

  private

  def profile_params
    params.require(:profile).permit(Profile::permitted_params)
  end

  def get_user
    raise ApiError.new("Не указано имя пользователя", :bad_request) if params[:name].blank?
    @user = User.find_by(name: params[:name])
    raise ApiError.new("Пользователь с таким именем не зарегистрирован", :not_acceptable) unless @user
  end
end
