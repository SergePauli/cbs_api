shared_examples "auditable" do
  it { is_expected.to have_many(:audits) }
end
