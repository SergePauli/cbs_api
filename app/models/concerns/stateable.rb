module Stateable
  extend ActiveSupport::Concern

  included do
    before_validation :check_if_exist, on: :create

    def check_if_exist
      # получаем чистые атрибуты стэйта
      state_attributes = state.attributes.filter { |k, v| v != nil }
      # если состояние уже присутствует в state.class - используем его,
      # чтоб избежать ошибки уникальности,
      # иначе создаем запись о новом состоянии
      self.state = state.class.where(state_attributes).first_or_initialize
      # if state.class.name == "Address"
      #   print 'state ', self.state.id," "
      #   puts self.state.value       
      # end
    end
  end
end
