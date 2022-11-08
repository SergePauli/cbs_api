class Naming < ApplicationRecord
  validates :name, presence: true
  validates :surname, presence: true
  validates :surname, uniqueness: { scope: [:name, :patrname] }

  def head
    "#{surname} #{name} #{patrname}".strip
  end
end
