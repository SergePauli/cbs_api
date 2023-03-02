# Персонализация автора изменений
# на случай если аккаунт пользователя или рабочий профиль
# перейдет к другому человеку
module Personable
  extend ActiveSupport::Concern

  included do
    belongs_to :person, class_name: "Person", foreign_key: "person_id", optional: true
    before_save :save_person_id

    def save_person_id
      self.person_id = self.user.person_id
    end
  end
end
