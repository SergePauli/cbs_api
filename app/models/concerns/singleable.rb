module Singleable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_is_single, if: -> { used? }

    def ensure_is_single
      return if self === nil
      another_used = self.class.where({ main_model_id: main_model_id, used: true })
      another_used = another_used.where.not({ id: id }) if id
      another_used.update({ used: false }) if another_used.first
    end
  end
end
