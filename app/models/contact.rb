class Contact < ApplicationRecord
  validates :value, presence: { message: ":value should be present" }
  validates :type, presence: { message: ":type should be present" }
  validates :type, inclusion: { in: %w(Email Fax Phone SiteUrl Telegram),
                                message: "%{value} is not a valid" }, allow_nil: false
  validates :type, uniqueness: { scope: :value }
end
