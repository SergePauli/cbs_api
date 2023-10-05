class ApplicationRecord < ActiveRecord::Base
  extend HasEnumConstants

  self.abstract_class = true

  # типовые опции для рендера данных модели
  def data_sets
    [:head, # только наименование
     :item, # элемент меню
     :card, # карточка
     :summary, # аудит изменений
     :edit # запись для редактирования
]
  end

  # кастомизация рендеринга модели в контроллере
  # принимает строку data_set - соответствующую одному из значений data_sets
  # возвращает кастомный объект соответствующий data_set
  def custom_data(data_set)
    if data_sets.include?(data_set)
      method = method(data_set)
      return method.call if method
    end
    false
  end

  #begin Дефолтная реализация методов для кастомного рендеринга

  def head
    name || to_s
  end

  def item
    { id: id, name: head }
  end

  def to_date_str(date)
    date.blank? ? nil : date.strftime("%a %b %d %Y")
  end

  def summary
    { created: created_at, updated: updated_at }
  end

  def card
    { head: head, id: id, summary: summary }
  end

  def edit
    { id: id }
  end

  #end Дефолтная реализация методов для кастомного рендеринга

  # разрешенные для обработки параметры запросов на изменение модели
  def self.permitted_params
    [:id]
  end
end
