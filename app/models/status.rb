class Status < NamedRecord
  # реализация для набора данных :item
  def item
    super.merge({ description: description })
  end

  # реализация для набора данных card
  def card
    super.merge({ description: description, order: order })
  end
end
