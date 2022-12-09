require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  fixtures :users
  let (:test_user) { users(:user) }

  describe "запрос о подтверждении аккаунта" do
    let(:mail) { ApplicationMailer.with(user_id: test_user.id).confirmation_mail }

    it "вывод заголовков" do
      expect(mail.subject).to eq("Запрос на активацию аккаунта")
      expect(mail.to).to eq([Rails.configuration.admin_mail])
      expect(mail.from).to eq([Rails.configuration.from_mail])
    end

    it "вывод тела письма" do
      expect(mail.body.encoded).to match(test_user.email)
      expect(mail.body.encoded).to match(test_user.activation_link)
    end
  end
  describe "Уведомление об активации аккаунта" do
    let(:mail) { ApplicationMailer.with(email: test_user.email, to: test_user.email).welcome_mail }

    it "вывод заголовков" do
      expect(mail.subject).to eq("Аккаунт был активирован")
      expect(mail.to).to eq([test_user.email])
      expect(mail.from).to eq([Rails.configuration.from_mail])
    end

    it "вывод тела письма" do
      expect(mail.body.encoded).to match(test_user.email)
      expect(mail.body.encoded).to match("успешно зарегистрирован")
    end
  end

  describe "Письмо со ссылкой на восстановление пароля пользователя" do
    let(:mail_pwd_renew) { ApplicationMailer.with(name: test_user.name, to: test_user.email, link: test_user.activation_link).pass_renew_mail }

    it "вывод заголовков" do
      expect(mail_pwd_renew.subject).to eq("Запрос на смену пароля")
      expect(mail_pwd_renew.to).to eq([test_user.email])
      expect(mail_pwd_renew.from).to eq([Rails.configuration.from_mail])
    end

    it "вывод тела письма" do
      expect(mail_pwd_renew.body.encoded).to match(test_user.name)
      expect(mail_pwd_renew.body.encoded).to match("Для изменения пароля переходите")
    end
  end
end
