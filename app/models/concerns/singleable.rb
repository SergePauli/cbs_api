module Singleable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_is_single, if: -> { used? }, on: :create

    def ensure_is_single
      return if self === nil
      another_used = self.class.where({ main_model_id: main_model_id, used: true })
      return unless another_used
      another_used = another_used.first
      another_used.update({ used: false }) if !!another_used
    end
  end
end
