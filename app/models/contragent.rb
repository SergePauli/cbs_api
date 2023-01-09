class Contragent < ApplicationRecord
  has_many :audits, primary_key: "obj_uuid", foreign_key: "obj_uuid"
  enum obj_type: [:organization, :person]
end
