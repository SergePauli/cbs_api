require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  fixtures :users
  describe "запрос о подтверждении аккаунта" do
    let(:mail) { ApplicationMailer.with(user_id: users(:user).id).confirmation_mail }

    it "вывод заголовков" do
      expect(mail.subject).to eq("Запрос на активацию аккаунта")
      expect(mail.to).to eq([Rails.configuration.admin_mail])
      expect(mail.from).to eq([Rails.configuration.from_mail])
    end

    it "вывод тела письма" do
      expect(mail.body.encoded).to match(users(:user).email)
      expect(mail.body.encoded).to match(users(:user).activation_link)
    end
  end
  describe "Уведомление об активации аккаунта" do
    let(:mail) { ApplicationMailer.with(email: users(:user).email, to: users(:user).email).welcome_mail }

    it "вывод заголовков" do
      expect(mail.subject).to eq("Аккаунт был активирован")
      expect(mail.to).to eq([users(:user).email])
      expect(mail.from).to eq([Rails.configuration.from_mail])
    end

    it "вывод тела письма" do
      expect(mail.body.encoded).to match(users(:user).email)
      expect(mail.body.encoded).to match("успешно зарегистрирован")
    end
  end
end
