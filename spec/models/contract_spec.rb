require "rails_helper"
require "models/concerns/executable_spec"
require "models/concerns/auditable_spec"
require "models/concerns/commentable_spec"
RSpec.describe Contract, type: :model do
  # поддерживает аудит изменений
  it_behaves_like "auditable"
  # комменты
  it_behaves_like "commentable"
  # статусы, сроки, задачи
  it_behaves_like "executable"

  # унаследовано от ApplicationRecord
  it { is_expected.to respond_to(:head, :card, :item, :custom_data, :data_sets) }
end
