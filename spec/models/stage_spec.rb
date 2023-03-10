require "rails_helper"

RSpec.describe Stage, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"
end
