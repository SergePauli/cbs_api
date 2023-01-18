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

  def secure_addition(obj)
    # получаем чистые атрибуты
    obj_attributes = obj.attributes.filter { |k, v| v != nil }
    # если состояние уже присутствует в obj.class - используем его,
    # чтоб избежать ошибки уникальности,
    # иначе создаем запись о новом состоянии
    obj.class.where(obj_attributes).first_or_initialize
  end

  private

  def ensure_is_unique
    if !!state && !state.id
      self.state = secure_addition state
    end
  end
end
