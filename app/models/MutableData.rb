# Функционал для хранения
# изменчивых данных
#
# Предполагается, что декомпозированая
# изменчивая часть данных связи (многие ко многим)
# хранится в атрибуте "state"
# или в поле с аналогичным алиасом

class MutableData < ApplicationRecord
  self.abstract_class = true

  before_validation :ensure_is_unique

  private

  def ensure_is_unique
    if !!state && !state.id
      # получаем чистые атрибуты стэйта
      state_attributes = state.attributes.filter { |k, v| v != nil }
      # если состояние уже присутствует в state.class - используем его,
      # чтоб избежать ошибки уникальности,
      # иначе создаем запись о новом состоянии
      self.state = state.class.where(state_attributes).first_or_initialize
    end
  end
end
