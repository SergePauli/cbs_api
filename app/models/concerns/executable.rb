#статусы контрактов(этапов)
module Executable
  extend ActiveSupport::Concern

  included do
    belongs_to :task_kind
    enum deadline_kind: [:calendar_plan, :calendar_days, :calendar_prepayment, :working_days, :working_prepayment]
    validates_associated :task_kind
  end
end
