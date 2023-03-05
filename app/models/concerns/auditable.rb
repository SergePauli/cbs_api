module Auditable
  extend ActiveSupport::Concern

  def self.no_audit_for
    ["comments_attributes"]
  end

  included do
    has_many :audits, as: :auditable
  end
end
