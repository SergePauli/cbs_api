# проверка валидности ролей пользователя на соответствие эталону в User::ROLES
class RoleValidator < ActiveModel::Validator
  def validate(record)
    return if !record.role
    notValid = ""
    if !record.role.split(",").reduce(true) do |valid, el|
      valid = User::ROLES.include? el if valid
      notValid += " #{el}" unless valid
      valid
    end
      record.errors.add :role, "Указаные роли пользователя недопустимы: #{notValid}"
    end
  end
end

# проверка наличия email у пользователя
class MailValidator < ActiveModel::Validator
  def validate(record)
    if record.person && record.person.email == nil
      record.errors.add :email, "У пользователя отсутствует email"
    end
  end
end

class User < NamedRecord
  before_create :before_create

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
  validates :name, format: { with: /\A[a-z0-9_-]{3,16}\z/, message: "недопустимое имя пользователя" }
  validates :role, format: { with: /\A\w(,\w)*/, message: "неверный массив ролей пользователя" }, allow_nil: true
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
  def self.new_activation_link
    SecureRandom.urlsafe_base64(25)
  end

  # колбэк при создании записи
  def before_create
    self.activation_link = User.new_activation_link
  end

  # begin Принимаем атрибуты для связанных моделей
  accepts_nested_attributes_for :person

  # получаем массив разрешенных параметров запросов на обновление
  def self.permitted_params
    super | [:role, :password, :password_confirmation, person_attributes: Person.permitted_params]
  end

  # end
end
