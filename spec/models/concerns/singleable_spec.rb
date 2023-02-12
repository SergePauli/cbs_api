shared_examples "singleable" do
  it { is_expected.to respond_to(:main_model_id, :ensure_is_single) }
end
