class Holiday < ApplicationRecord
  # набор данных card
  def card
    super.merge({ name: name, begin_at: to_date_str(begin_at), end_at: to_date_str(end_at), work: work })
  end

  # получаем массив разрешенных параметров запросов на добавление и изменение
  def self.permitted_params
    super | [:name, :begin_at, :end_at, :work]
  end
end
