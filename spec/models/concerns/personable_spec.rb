shared_examples "personable" do
  it { is_expected.to belongs_to(:person) }
  it { is_expected.to belongs_to(:user) }
  it { is_expected.to respond_to(:save_person_id) }
end
