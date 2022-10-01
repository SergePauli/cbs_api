class Contact < ApplicationRecord
  belongs_to :ContactType
  attr_accessible :name

  acts_as_ati :type, :class_name => ContactType,
                     :foreign_key => :contact_type_id,
                     :field_name => :name do |type|
    "#{type}Contact"
  end
end
