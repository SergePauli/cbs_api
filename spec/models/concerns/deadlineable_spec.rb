shared_examples "deadlineable" do
  it { is_expected.to have_db_column(:deadline_kind).of_type(:integer) }

  it "возврат permitted_params должен включать :deadline_kind" do
    expect(subject.class.permitted_params).to include(:deadline_kind)
  end
end
