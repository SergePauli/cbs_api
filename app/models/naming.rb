class Naming < ApplicationRecord
  validates :name, presence: true
  validates :surname, presence: true
  validates :surname, uniqueness: { scope: [:name, :patrname] }

  def head
    "#{surname} #{name} #{patrname.blank? ? "" : patrname}".strip
  end

  def edit
    super.merge({ surname: surname, name: name, patrname: patrname })
  end

  def self.permitted_params
    super | [:name, :surname, :patrname]
  end

  ransacker :fio do
    query = "(SELECT concat(namings.surname, ' ',namings.name,' ',namings.patrname))"
    Arel.sql(query)
  end
end
