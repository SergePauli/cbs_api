# Функционал для хранения
# изменчивых данных
#
# Предполагается, что декомпозированая
# изменчивая часть данных связи (многие ко многим)
# хранится в атрибуте "state"
# или в поле с аналогичным алиасом

class MutableData < ApplicationRecord
  self.abstract_class = true

  validates :list_key, presence: true, uniqueness: true

  def head
    used ? state.head : "*" + state.head
  end

  def item
    super.merge({ priority: priority })
  end

  def card
    super.merge({ priority: priority, used: used, list_key: list_key })
  end

  def self.permitted_params
    super | [:used, :priority, :list_key, :_destroy]
  end
end
