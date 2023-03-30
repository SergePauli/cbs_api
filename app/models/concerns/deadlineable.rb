#типы расчета сроков завершения контрактов(этапов)
module Deadlineable
  extend ActiveSupport::Concern

  included do
    enum deadline_kind: [:calendar_plan, :calendar_days, :calendar_prepayment, :working_days, :working_prepayment]
  end
end
