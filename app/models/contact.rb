class Contact < ApplicationRecord
  # аудит изменений
  include Auditable

  validates :value, presence: { message: ":value should be present" }
  validates :type, presence: { message: ":type should be present" }
  validates :type, inclusion: { in: %w(Email Fax Phone SiteUrl Telegram),
                                message: "%{value} is not a valid" }, allow_nil: false
  validates :value, uniqueness: { scope: :type }

  alias_attribute :name, :value

  def card
    super.merge({ type: type, audits: audits })
  end

  def item
    super.merge({ type: type })
  end

  def self.permitted_params
    super | [:value, :name, :type]
  end
end
