# профиль пользователя
# пользователь может иметь много профилей
class Profile < MutableData
  belongs_to :user
  belongs_to :position
  belongs_to :department, optional: true

  validates_associated :user
  validates_associated :position
  validates_associated :department
  validates :statuses, format: { with: /\A\d,(\d,)+\d/, message: "invalid array of statuses" }, allow_nil: true
  validates :contracts_types, format: { with: /\A\d{1,2},(\d{1,2},)+\d{1,2}/, message: "invalid array of types" }, allow_nil: true
  validates :user, uniqueness: { scope: :position }
  alias_attribute :state, :position # для поддержки MutableData

  # реализация для набора данных head
  def head
    tmp = "#{user.name} #{position.name}"
    tmp = "*" + tmp unless used
    tmp
  end

  # реализация для набора данных card
  def card
    super.merge({ user: user.item, position: position.item,
                  department: department ? department.item : nil,
                  statuses: statuses || position.def_statuses || (department ? department.def_statuses : nil),
                  contracts_types: contracts_types || position.def_contracts_types || (department ? department.def_contracts_types : nil) })
  end

  # реализация для набора данных edit
  def edit
    super.merge({ name: head, user: user.edit, position: position.item,
                  department: department ? department.item : nil })
  end

  # begin Принимаем атрибуты для связанных моделей
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :position

  # получаем массив разрешенных параметров запросов на обновление
  def self.permitted_params
    super | [:department_id, :user_id, :position_id, :statuses, :contracts_types, user_attributes: User.permitted_params, position_attributes: Position.permitted_params]
  end

  # end
end
