shared_examples "executable" do
  it { is_expected.to have_db_column(:status_id).of_type(:integer) }
  it { is_expected.to have_db_column(:deadline_kind).of_type(:integer) }

  it "возврат permitted_params должен включать :status_id" do
    expect(subject.class.permitted_params).to include(:status_id)
  end
  it "возврат permitted_params должен включать :task_kind_id" do
    expect(subject.class.permitted_params).to include(:task_kind_id)
  end
  it "возврат permitted_params должен включать :deadline_kind" do
    expect(subject.class.permitted_params).to include(:deadline_kind)
  end
end
