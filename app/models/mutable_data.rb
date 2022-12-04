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

  def head
    state.head
  end

  def item
    super.merge({ used: used, priority: priority })
  end

  def self.permitted_params
    super | [:used, :priority, :_destroy]
  end

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
