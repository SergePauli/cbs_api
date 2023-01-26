module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audits, as: :auditable
  end
end
