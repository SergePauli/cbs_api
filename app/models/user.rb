# проверка валидности ролей пользователя на соответствие эталону в User::ROLES
class RoleValidator < ActiveModel::Validator
  def validate(record)
    return if !record.role
    if !record.role.split(",").reduce(true) do |valid, el|
      valid = User::ROLES.include? el if valid
      valid
    end
      record.errors.add :role, "User role contains not valid value"
    end
  end
end

class MailValidator < ActiveModel::Validator
  def validate(record)
    if record.person && record.person.email == nil
      record.errors.add :email, "User email absend"
    end
  end
end

class User < NamedRecord
  after_initialize :new_activation_link

  # константы для ролей пользователя
  constants_group :ROLES do
    constant :ADMIN
    constant :USER
  end

  # хелпер для bcript авторизации
  has_secure_password

  # привязка к персональным данным
  belongs_to :person
  validates_associated :person

  # валидация ролей пользователя
  validates :role, format: { with: /\A\w(,\w)*/, message: "invalid roles array" }, allow_nil: true
  validates_with RoleValidator, MailValidator

  # реализация для набора данных head
  def head
    "#{name} #{person.head}"
  end

  # реализация для набора данных card
  def card
    super.merge({ role: role, person: person.card, last_login: last_login })
  end

  # получение email
  def email
    person.email.value
  end

  # генерация новой ссылки
  def new_activation_link
    self.activation_link = SecureRandom.base64(20)
    self.activated = false
  end
end
