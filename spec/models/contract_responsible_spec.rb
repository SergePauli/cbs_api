require "rails_helper"

RSpec.describe ContractResponsible, type: :model do
  fixtures :contract_responsibles, :contracts, :employees, :contragents, :people, :positions

  let(:responsible) { contract_responsibles(:client_contract) }

  it "связывает контракт с ответственным сотрудником" do
    expect(responsible.contract).to eq contracts(:krabcom_01_23_01)
    expect(responsible.employee).to eq employees(:client)
    expect(responsible.contract.responsible_employees).to include(employees(:client))
  end

  it "возвращает набор данных :head аналогично исполнителю этапа" do
    expect(responsible.head).to eq responsible.employee.head

    responsible.used = false

    expect(responsible.head).to eq "*#{responsible.employee.head}"
  end

  it "возвращает набор данных :item аналогично исполнителю этапа" do
    expect(responsible.item).to eq({
      id: responsible.id,
      name: responsible.head,
      priority: responsible.priority
    })
  end

  it "не допускает повторного назначения сотрудника" do
    duplicate = described_class.new(
      contract: responsible.contract,
      employee: responsible.employee,
      list_key: SecureRandom.uuid
    )

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:employee_id]).not_to be_empty
  end

  it "не допускает сотрудника другого контрагента" do
    other_employee = Employee.create!(
      contragent: contragents(:med_rzd),
      person: people(:admin),
      position: positions(:admin),
      list_key: SecureRandom.uuid
    )

    assignment = described_class.new(
      contract: responsible.contract,
      employee: other_employee,
      list_key: SecureRandom.uuid
    )

    expect(assignment).not_to be_valid
    expect(assignment.errors[:employee]).not_to be_empty
  end

  it "возвращает данные для редактирования" do
    expect(responsible.edit[:employee_id]).to eq responsible.employee_id
    expect(responsible.edit[:employee]).to eq responsible.employee.item
  end
end
