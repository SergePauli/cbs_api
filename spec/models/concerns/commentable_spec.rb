shared_examples "commentable" do
  it { is_expected.to have_many(:comments) }
  it { is_expected.to accept_nested_attributes_for(:comments) }

  it "возврат permitted_params должен включать :comments_attributes" do
    expect(subject.class.permitted_params).to include(comments_attributes: Comment.permitted_params)
  end
end
