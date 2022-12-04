class Auth::RegistrationController < ApplicationController
  include ActionController::Cookies

  # POST auth/registration
  def registration
    @profile = Profile.new(profile_params)
    if @profile.save
      #ApplicationMailer.with(user_id: @user.id).confirmation_mail.deliver_later
      render status: :ok
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET auth/activation
  def activation
    @user = User.where(activation_link: params[:link]).first
    if @user && !@user.activated
      @user.activated = true
      if @user.save
        #ApplicationMailer.with(email: @user.email, to: Rails.configuration.admin_mail).welcome_mail.deliver_later
        #ApplicationMailer.with(email: @user.email, to: @user.email).welcome_mail.deliver_later
        redirect_to "http://#{Rails.configuration.client_url}/message/Аккаунт успешно активирован"
      end
    elsif @user && @user.activated
      redirect_to "http://#{Rails.configuration.client_url}/message/Аккаунт был активирован ранее"
    else
      redirect_to "http://#{Rails.configuration.client_url}/message/Ссылка не действительна"
    end
  end

  private

  def profile_params
    params.require(:profile).permit(Profile::permitted_params)
  end
end
