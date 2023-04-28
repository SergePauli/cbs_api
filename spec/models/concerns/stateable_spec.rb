shared_examples "stateable" do
  it { is_expected.to respond_to(:state) }
end
